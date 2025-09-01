--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
import           Hakyll
import           Text.Pandoc.Options
import           System.Environment (lookupEnv)
import           Data.Maybe (isJust)
import           Control.Monad

import Data.Text.IO qualified as T
import Data.Text qualified as T
import System.Environment (getArgs)
import Text.Pandoc hiding (lookupEnv)
import Text.Pandoc.Walk
import Hakyll.Core.Compiler.Internal
import Text.Pandoc.Readers.Typst    (readTypst)
import Text.Pandoc.Writers.Markdown (writeMarkdown)
import Text.Pandoc.Extensions       (pandocExtensions)
import System.FilePath ((</>))
import System.Directory
--
--------------------------------------------------------------------------------
main :: IO ()
main = do 
  prod <- isJust <$> lookupEnv "PROD"
  let myDefaultContext = mconcat
                         [ boolField "prod" (const prod)
                         , constField "root" root
                         , defaultContext ]
  hakyll $ do
    match "images/*" $ do
      route   idRoute
      compile copyFileCompiler

    match "css/*" $ do
      route   idRoute
      compile compressCssCompiler

    match (fromList ["CNAME", "favicon.ico", "robots.txt"]) $ do
      route   idRoute
      compile copyFileCompiler

    match "pages/*" $ do
      route   $ gsubRoute "pages/" (const "") `composeRoutes` setExtension "html"
      compile $ pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" myDefaultContext
        >>= relativizeUrls

    tags <- buildTags "posts/**" (fromCapture "tags/*.html")
    let myPostCtx = mconcat
                    [ dateField "date" "%B %e, %Y"
                    , tagsField "tags" tags
                    , myDefaultContext ]
    tagsRules tags $ \tag pat -> do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll pat
        let myTagPageCtx = mconcat
              [ listField "posts" myPostCtx (return posts)
              , constField "title" $ "Posts tagged \"" ++ tag ++ "\""
              , boolField "noindex" (pure True)
              , myDefaultContext ]

        makeItem ""
          >>= loadAndApplyTemplate "templates/tag.html" myTagPageCtx
          >>= loadAndApplyTemplate "templates/default.html" myTagPageCtx
          >>= relativizeUrls

    match "posts/**" $ do
      route $ setExtension "html"
      compile $ customPandocCompiler
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/post.html"    myPostCtx
        >>= loadAndApplyTemplate "templates/default.html" myPostCtx
        >>= relativizeUrls

    create ["archive.html"] $ do
      route idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/**"
        tagList <- renderTagList tags
        let myArchiveCtx = 
              listField "posts" myPostCtx (return posts) `mappend`
              constField "taglist"  tagList             `mappend`
              constField "title" "Archives"            `mappend`
              myDefaultContext 

        makeItem ""
          >>= loadAndApplyTemplate "templates/archive.html" myArchiveCtx
          >>= loadAndApplyTemplate "templates/default.html" myArchiveCtx
          >>= relativizeUrls

    create ["sitemap.xml"] $ do
      route   idRoute
      compile $ do
        posts <- recentFirst =<< loadAll "posts/*"
        pages <- loadAll "pages/*"
        let allPages = return (pages ++ posts)
        let sitemapCtx = mconcat
                         [ listField "pages" myPostCtx allPages
                         , myDefaultContext
                         ]
        makeItem ""
          >>= loadAndApplyTemplate "templates/sitemap.xml" sitemapCtx

    create ["rss.xml"] $ do
      route idRoute
      compile $ do
        let feedCtx = mconcat
                      [ teaserField "teaser" "content"
                      , bodyField "description"
                      , myPostCtx
                      ]
            absolutizeUrl u = if isExternal u then u else root ++ u
        posts <- fmap (take 10) . recentFirst =<<
          loadAllSnapshots "posts/*" "content"
        processedPosts <- forM posts $
          \p -> do pp <- loadAndApplyTemplate "templates/rss-description.html" feedCtx p
                   return $ fmap (withUrls absolutizeUrl) pp
        renderRss myFeedConfiguration feedCtx processedPosts

    match "index.html" $ do
      route idRoute
      compile $ do
        posts <- fmap (take 5) . recentFirst =<< loadAllSnapshots "posts/*" "content"
        let myTeaserPostCtx =
              teaserField "teaser" "content" <> myPostCtx
            myIndexCtx = mconcat
                         [ listField "posts" myTeaserPostCtx (return posts)
                         , constField "canonical" (root ++ "/")
                         , constField "homepage" "yes"
                         , myDefaultContext ]

        getResourceBody
          >>= applyAsTemplate myIndexCtx
          >>= loadAndApplyTemplate "templates/default.html" myIndexCtx
          >>= relativizeUrls

    match "about/*" $ compile templateBodyCompiler
    match "templates/*" $ compile templateBodyCompiler

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

texifyInline :: Inline -> PandocIO Inline
texifyInline = \case
      Math dispType typstMath -> do 
        texMathMb <- readTypst def ("$ " <> typstMath <> " $")
        let texMath = case texMathMb of
                        (Pandoc _ [Para [Math _disp texMathText]]) -> texMathText
                        _huh -> "could not parse ????: " <> T.pack (show texMathMb)
        pure $ Math dispType texMath
      x -> pure x

-- | converts a Pandoc document with inline Typst to inline TeX
texifyTypst :: Pandoc -> IO Pandoc
texifyTypst (Pandoc meta blocks)  = do
  blocksMb' <- runIO $ walkM texifyInline blocks
  blocks' <- handleError blocksMb'
  pure $ Pandoc meta blocks'

--------------------------------------------------------------------------------
-- Blog Descriptions
--------------------------------------------------------------------------------

root :: String
root = "https://blog.hbae.com"

customPandocCompiler :: Compiler (Item String)
customPandocCompiler =
  let myExtensions = mconcat $ map enableExtension
          [ Ext_lists_without_preceding_blankline
          , Ext_fancy_lists
          , Ext_example_lists
          , Ext_definition_lists
          , Ext_tex_math_single_backslash
          ]
      defaultReaderExtensions = readerExtensions defaultHakyllReaderOptions
      readerOptions = defaultHakyllReaderOptions {
        readerExtensions =  myExtensions defaultReaderExtensions
        }

      defaultWriterExtensions = writerExtensions defaultHakyllWriterOptions
      writerOptions = defaultHakyllWriterOptions {
        writerExtensions = enableExtension Ext_tex_math_single_backslash defaultWriterExtensions,
          writerHTMLMathMethod = MathJax ""
        }
  in pandocCompilerWithTransformM readerOptions writerOptions (compilerUnsafeIO . texifyTypst)

myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "Harrison Centner's blog"
    , feedDescription = "My blog --- programming, maths, and security"
    , feedAuthorName  = "Harrison Centner"
    , feedAuthorEmail = "hcentner@umich.edu"
    , feedRoot        = root
    }
