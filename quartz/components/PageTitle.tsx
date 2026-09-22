import { pathToRoot } from "../util/path"
import { QuartzComponentConstructor, QuartzComponentProps } from "./types"

function PageTitle({ fileData, cfg, displayClass }: QuartzComponentProps) {
  const title = cfg?.pageTitle ?? "Untitled Quartz"
  const baseDir = pathToRoot(fileData.slug!)
  // The banner is the way to the About page, not to the root: the root is the
  // latest fragment, which the graph and the fragments themselves already
  // reach. On About the click is intercepted and toggles the banner instead
  // (see scripts/bannertoggle.inline.ts).
  return (
    <h1 class={`page-title ${displayClass ?? ""}`}>
      <a href={`${baseDir}/about`}>{title}</a>
    </h1>
  )
}

PageTitle.css = `
.page-title {
  margin: 0;
}
`

export default (() => PageTitle) satisfies QuartzComponentConstructor
