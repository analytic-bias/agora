-- TODO https://pandoc.org/lua-filters.html#building-images-with-tikz

local system = require 'pandoc.system'
local fun = require 'fun'
local inspect = require 'inspect'

local tikz_doc_template = [[
\documentclass{standalone}
\usepackage{xcolor}
\usepackage{tikz}
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
      os.execute('pdflatex tikz.tex')
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
  '\\begin{tikzpicture}'
}

function RawBlock(el)
  t = fun.filter(function(x) return starts_with(x, el.text) end, triggers)
  print(fun.length(t))
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