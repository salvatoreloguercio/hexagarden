import { PageLayout, SharedLayout } from "./quartz/cfg"
import * as Component from "./quartz/components"
import { SimpleSlug } from "./quartz/util/path"

// components shared across all pages
export const sharedPageComponents: SharedLayout = {
  head: Component.Head(),
  header: [],
  footer: Component.Footer({
    links: {
      GitHub: "https://github.com/salvatoreloguercio",
      Twitter: "https://twitter.com/loguerci",
    },
  }),
}

// components for pages that display a single page (e.g. a single note)
export const defaultContentPageLayout: PageLayout = {
  // PageTitle is the full-bleed banner. It has to sit outside the sidebars,
  // which bare mode hides.
  beforeBody: [Component.PageTitle(), Component.BannerToggle(), Component.ArticleTitle(), Component.ContentMeta()],
  left: [
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
  ],
  right: [
    Component.DesktopOnly(Component.Graph({
      localGraph: {
        depth: 2,            // fragment -> its tags -> other fragments on those tags
        scale: 1.1,
        opacityScale: 4,     // (4-1)/3.75 = 0.8 — labels actually visible
        fontSize: 0.55,
        repelForce: 0.7,     // spread the heap out rather than clumping it
        centerForce: 0.25,
        linkDistance: 40,
        showTags: true,      // REQUIRED — every edge runs fragment -> tag -> fragment
      },
      globalGraph: {
        depth: -1,
        scale: 0.85,
        opacityScale: 4,
        fontSize: 0.5,
        repelForce: 0.8,
        centerForce: 0.2,
        linkDistance: 45,
        showTags: true,
      },
    })),
    Component.Backlinks(),
  ],
}

// components for pages that display lists of pages  (e.g. tags or folders)
export const defaultListPageLayout: PageLayout = {
  beforeBody: [Component.PageTitle(), Component.BannerToggle(), Component.ArticleTitle()],
  left: [
    Component.MobileOnly(Component.Spacer()),
    Component.Search(),
    Component.Darkmode(),
  ],
  right: [],
}
