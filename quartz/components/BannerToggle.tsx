// A new file rather than an edit to PageTitle: additive components survive a
// Quartz upgrade as a copy, where modified upstream files become a merge.
// @ts-ignore
import script from "./scripts/bannertoggle.inline"
import { QuartzComponentConstructor } from "./types"

// Renders nothing. It exists to carry the script that makes the index banner
// expand and contract.
function BannerToggle() {
  return null
}

BannerToggle.afterDOMLoaded = script

export default (() => BannerToggle) satisfies QuartzComponentConstructor
