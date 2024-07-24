local system = require 'pandoc.system'
local fun = require 'fun'
local inspect = require 'inspect'

local function starts_with(start, str)
  return str:sub(1, #start) == start
end

function Math(el)
  if el.mathtype == "DisplayMath" and starts_with('html', FORMAT) then
    local tex = el.text
    local tags = {}
    local new_tex = tex:gsub("\\tag{.*}", function(tag)
      tags[#tags + 1] = tag
      return ""
    end)
    el.text = new_tex
  end
  return el
end

-- function RawInline(el)
--   if el.format == "latex" then
--     print(el.text)
--     el.text = el.text:gsub('\\marginnote{', '\\marginpar{')
--   end
--   return el
-- end

-- function RawBlock(el)
--   if el.format == "latex" then
--     print(el.text)
--     el.text = el.text:gsub('\\marginnote{', '\\marginpar{')
--   end
--   return el
-- end
