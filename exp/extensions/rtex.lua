-- TODO https://pandoc.org/lua-filters.html#building-images-with-tikz

local system = require 'pandoc.system'
local fun = require 'fun'
local inspect = require 'inspect'

local html_template = [[
\documentclass[border={10pt 10pt 10pt 10pt}]{standalone}
\usepackage{graphics}
\usepackage{xcolor}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{amsfonts}
\usepackage{mathtools}
\usepackage{unicode-math}
\usepackage{pgfplots}
\usepackage{relsize}
\usepackage{tikz}
\usepackage{frege}
\usepackage{wrapfig}
\usepackage{soul}
\usepackage{quiver}
\usetikzlibrary{fit,tikzmark}
\newenvironment{dummyenv}{}{}
\begin{document}
\nopagecolor
%s
\end{document}
]]

local tex_template = [[
\documentclass[border={10pt 10pt 10pt 10pt}]{standalone}
\usepackage{graphics}
\usepackage{xcolor}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{amsfonts}
\usepackage[]{libertinus}
\setmathfont{TeX Gyre Termes Math}[range=\smwhtdiamond]
\setmathfont{LibertinusMath-Regular.otf}[range=]
\usepackage{mathtools}
\usepackage{unicode-math}
\usepackage{pgfplots}
\usepackage{relsize}
\usepackage{tikz}
\usepackage{frege}
\usepackage{wrapfig}
\usepackage{soul}
\usepackage{quiver}
\usetikzlibrary{fit,tikzmark}
\newenvironment{dummyenv}{}{}
\begin{document}
\nopagecolor
%s
\end{document}
]]

local function tikz2image(src, outfile)
  system.with_temporary_directory('tikz2image', function (tmpdir)
    system.with_working_directory(tmpdir, function()
      local f = io.open('tikz.tex', 'w')
      f:write(html_template:format(src))
      f:close()
      os.execute('xelatex -shell-escape tikz.tex')
      os.execute('xelatex -shell-escape tikz.tex')
      os.execute('pdf2svg tikz.pdf ' .. outfile .. '.svg')

      local f = io.open('tikz1.tex', 'w')
      f:write(tex_template:format(src))
      f:close()
      os.execute('xelatex -shell-escape tikz1.tex')
      os.execute('xelatex -shell-escape tikz1.tex')
      os.execute('cp tikz1.pdf ' .. outfile .. '.pdf')
    end)
  end)
end

local function file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

local function starts_with(start, str)
  return str:sub(1, #start) == start
end

local triggers = {
  '\\begin{tikzpicture}',
  '\\begin{tikzcd}',
  '\\begin{dummyenv}'
}

function RawBlock(el)
  t = fun.filter(function(x) return starts_with(x, el.text) end, triggers)
  if fun.length(t) ~= 0 then
    local fbasename = pandoc.sha1(el.text)
    local fname = system.get_working_directory() .. '/' .. fbasename
    if not file_exists(fname .. '.svg') then
      tikz2image(el.text, fname)
    end
    print(FORMAT)
    if starts_with('html', FORMAT) then
      print(fbasename .. '.svg')
      local img = pandoc.Image({}, fbasename .. '.svg')
      img.attributes.style = 'display: block; margin: auto; width: 100%;'
      return pandoc.Para({img})
    else
      local img = pandoc.Image({}, fbasename .. '.pdf')
      img.attributes.style = 'display: block; margin: auto; width: 100%;'
      return pandoc.Para({img})
    end
  else
    return el
  end
end

-- https://github.com/quarto-dev/quarto-cli/issues/7534
Note = function(n)
  n.content = pandoc.Para(pandoc.utils.blocks_to_inlines(n.content, {pandoc.RawInline('latex', '\n\\endgraf\n')}))
  return n
end
