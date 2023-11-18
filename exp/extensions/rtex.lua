-- TODO https://pandoc.org/lua-filters.html#building-images-with-tikz

local system = require 'pandoc.system'
local fun = require 'fun'
local inspect = require 'inspect'

local tikz_doc_template = [[
\documentclass{standalone}
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
\usepackage{quiver}
\newenvironment*{dummyenv}{}{}
\begin{document}
\nopagecolor
%s
\end{document}
]]

local function tikz2image(src, filetype, outfile)
  system.with_temporary_directory('tikz2image', function (tmpdir)
    system.with_working_directory(tmpdir, function()
      local f = io.open('tikz.tex', 'w')
      f:write(tikz_doc_template:format(src))
      f:close()
      os.execute('xelatex -shell-escape tikz.tex')
      if filetype == 'pdf' then
        os.rename('tikz.pdf', outfile)
      else
        os.execute('pdf2svg tikz.pdf ' .. outfile)
      end
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
  -- print("aaaaaaaaaaaa")
  if fun.length(t) ~= 0 then
    if starts_with('html', FORMAT) then
      local filetype = 'svg'
      local fbasename = pandoc.sha1(el.text) .. '.' .. filetype
      local fname = system.get_working_directory() .. '/' .. fbasename
      if not file_exists(fname) then
        tikz2image(el.text, filetype, fname)
      end
      return pandoc.Para({pandoc.Image({}, fbasename)})
    else
      return el
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
