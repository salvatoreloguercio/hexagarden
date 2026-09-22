// On the index the banner is a control rather than a link: it opens to the
// full Chi-Rho composition and closes back to the band. Everywhere else it
// stays what it has always been, the only way home.
//
// The open state is deliberately not remembered. Arriving at the index from a
// fragment should show the same band the fragment had, so the banner grows
// only when someone asks it to.

function toggleBanner(ev: Event) {
  ev.preventDefault()
  // Quartz's router listens for clicks on `window` and does not check
  // defaultPrevented (spa.inline.ts), so preventDefault alone is not enough —
  // without this it navigates to the index anyway, which re-fires `nav` and
  // clears the class we just set.
  ev.stopPropagation()
  const open = document.body.classList.toggle("banner-open")
  const link = ev.currentTarget as HTMLElement
  link.setAttribute("aria-expanded", String(open))
  link.setAttribute("aria-label", open ? "Collapse the banner" : "Expand the banner")
}

document.addEventListener("nav", () => {
  const link = document.querySelector<HTMLElement>(".page-title a")
  if (!link) return

  // stable reference, so this does not stack a listener per SPA navigation
  link.removeEventListener("click", toggleBanner)
  document.body.classList.remove("banner-open")

  if (document.body.dataset.slug === "index") {
    link.addEventListener("click", toggleBanner)
    link.setAttribute("aria-expanded", "false")
    link.setAttribute("aria-label", "Expand the banner")
  } else {
    link.removeAttribute("aria-expanded")
    link.removeAttribute("aria-label")
  }
})
