
function lookupclassmath(e) {
  if (e.classList.contains('math')) { return e } else { return lookupclassmath(e.parentElement) }
}

const almar = document.getElementsByClassName("almar")
const alref = document.getElementsByClassName("alref")

function alignmargin() {
  if (window.screen.width >= 768) {
    Array.from(almar).forEach((m, i) => {
      m.parentElement.setAttribute('backup-style-position', m.parentElement.style.position)
      m.parentElement.style.position = 'relative'
      m.parentElement.setAttribute('backup-style-height', m.parentElement.style.height)
      m.parentElement.style.height = '0px'
      m.setAttribute('backup-style-position', m.style.position)
      m.style.position = 'absolute'
      m.setAttribute('backup-style-padding', m.style.padding)
      m.style.padding = '0px'
      const r = Array.from(alref).filter(e => e.id != '').find(e => e.id.match('\\d+')[0] == m.id.match('\\d+')[0])
      m.setAttribute('backup-style-top', m.style.top)
      m.style.top = (r.getBoundingClientRect().top - lookupclassmath(r).getBoundingClientRect().top) + 'px'
    });
  } else {
    Array.from(almar).forEach((m, i) => {
      m.parentElement.style.position = m.parentElement.getAttribute('backup-style-position')
      m.parentElement.style.height = m.parentElement.getAttribute('backup-style-height')
      m.style.position = m.getAttribute('backup-style-position')
      m.style.padding = m.getAttribute('backup-style-height')
      m.style.top = m.getAttribute('backup-style-top')
    });
  }
}

window.MathJax = {
  startup : {
    pageReady : () => {
      return MathJax.startup.defaultPageReady().then(() => {  
        alignmargin();
      })
    }
  }
}

window.addEventListener("resize", alignmargin);

