
function lookupclassmath(e) {
  if (e.classList.contains('math')) { return e } else { return lookupclassmath(e.parentElement) }
}

const almar = document.getElementsByClassName("almar")
const alref = document.getElementsByClassName("alref")

window.MathJax = {
  startup : {
    pageReady : () => {
      return MathJax.startup.defaultPageReady().then(() => {  
        Array.from(almar).forEach((m, i) => {
          m.parentElement.style.position = 'relative'
          m.parentElement.style.height = '0px'
          m.style.position = 'absolute'
          m.style.padding = '0px'
          const r = Array.from(alref).filter(e => e.id != '').find(e => e.id.match('\\d+')[0] == m.id.match('\\d+')[0])
          m.style.top = (r.getBoundingClientRect().top - lookupclassmath(r).getBoundingClientRect().top) + 'px'
        });
      })
    }
  }
}
