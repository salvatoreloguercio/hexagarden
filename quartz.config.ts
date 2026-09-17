import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

const config: QuartzConfig = {
  configuration: {
    // Rendered into `.page-title a`, then pushed off-screen by text-indent
    // in quartz/styles/custom.scss. The illuminated crop is the only visible
    // home link, but the name still reaches screen readers, the tab order and
    // the document title.
    pageTitle: "hexagarden",
    enableSPA: true,
    enablePopovers: true,
    analytics: {
      provider: "plausible",
    },
    // Was "quartz.jzhao.xyz" — the template default. That broke RSS, the
    // sitemap and every Open Graph URL. Must include the subpath: this is a
    // GitHub Pages *project* site, served from the hexagarden repo.
    baseUrl: "salvatoreloguercio.github.io/hexagarden",
    ignorePatterns: ["private", "templates", ".obsidian"],
    defaultDateType: "created",
    theme: {
      typography: {
        // Mono labels, serif content: the titles are machine artifacts,
        // the fragments are not.
        header: "IBM Plex Mono",
        body: "EB Garamond",
        code: "IBM Plex Mono",
      },
      colors: {
        // Light mode is kept sane but is not the intended way to read the
        // site. Warm parchment rather than Quartz's cool default grays.
        lightMode: {
          light: "#f4efe4",
          lightgray: "#e0d8c6",
          gray: "#a89a82",
          darkgray: "#463d2e",
          dark: "#241f17",
          secondary: "#8a5f18",
          tertiary: "#8f3222",
          highlight: "rgba(138, 95, 24, 0.10)",
        },
        // Sampled from lindisfarne1.gif: ochre, gold, oxblood, no blue.
        darkMode: {
          light: "#0e0d0b",
          lightgray: "#2a2419",
          gray: "#6d6355",
          darkgray: "#d9d0be",
          dark: "#efe7d5",
          secondary: "#b5842c",
          tertiary: "#8f3222",
          highlight: "rgba(181, 132, 44, 0.10)",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.TableOfContents(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "filesystem"],
      }),
      Plugin.SyntaxHighlighting(),
      Plugin.Poetry(),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Latex({ renderEngine: "katex" }),
      Plugin.Description(),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources({ fontOrigin: "googleFonts" }),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
