-- ~/.config/nvim/after/ftplugin/tla.lua
--
-- Indentation for TLA+ files containing PlusCal.
--
-- Inside a PlusCal algorithm (p-syntax or c-syntax):
--   * blocks: begin/end, while…do, if…then/elsif/else, either/or, with…do,
--     define, macro/procedure, and { } in c-syntax
--   * closers (end …, else, elsif, or, }) line up with the line that opened them
--   * labels on their own line indent their body; sibling labels line up
--   * `begin` lines up with its process/procedure/macro/algorithm header
-- Outside the algorithm (plain TLA+, and inside `define`):
--   * existing indentation is never changed by = or gg=G
--   * new lines after `Foo == /\ a` line up under the /\ (also \/, ∧, ∨)
--   * new lines after a bare `Foo ==` are indented one level
--   * finishing typing `Bar ==` snaps it back to definition level (not in LET)
--
-- Labels must be written `Name:` (no space before the colon).
-- If you prefer c-syntax, braces are handled too; no extra setup needed.

vim.bo.expandtab = true -- TLA+ is alignment-sensitive; never use tabs
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.autoindent = true
vim.bo.smartindent = false
vim.bo.cindent = false

local OPENERS = {
  begin = true, ["do"] = true, ["then"] = true, ["else"] = true,
  either = true, ["or"] = true, define = true,
}
local CLOSERS = { ["end"] = true, ["else"] = true, elsif = true, ["or"] = true }
local MAX_SCAN = 2000 -- don't look back further than this many lines

-- Line text without comments or surrounding whitespace.
local function strip(lnum)
  local s = vim.fn.getline(lnum)
  s = s:gsub("%(%*.-%*%)", "") -- inline (* … *)
  s = s:gsub("\\%*.*$", "") -- \* to end of line
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_opener(s)
  if s:sub(-1) == "{" then return true end
  local last = s:match("(%a+)$")
  return last ~= nil and OPENERS[last] == true
end

local function is_closer(s)
  if s:sub(1, 1) == "}" then return true end
  local first = s:match("^(%a+)")
  return first ~= nil and CLOSERS[first] == true
end

-- Labels are written `Name:` with no space before the colon. Requiring that
-- keeps `x :=` from being mistaken for a label while you're typing it.
local function is_label(s)
  return s:match("^[%a_][%w_]*:") ~= nil and s:match("^[%a_][%w_]*:=") == nil
end

local function is_label_only(s)
  return is_label(s) and s:match("^[%a_][%w_]*:$") ~= nil
end

-- Top-level sections of an algorithm
local function is_section(s)
  return s:match("^define%f[%W]") or s:match("^macro%f[%W]")
    or s:match("^procedure%f[%W]") or s:match("^process%f[%W]")
    or s:match("^fair%f[%W]") -- fair process / fair+ process
end

-- Start of a TLA+ operator definition: Foo ==, Foo(x) ==, f[x \in S] ==
local function is_definition(s)
  s = s:gsub("^LOCAL%s+", "")
  for _, def in ipairs({ "==", "≜" }) do
    if s:match("^[%a_][%w_]*%s*" .. def) or s:match("^[%a_][%w_]*%b()%s*" .. def)
      or s:match("^[%a_][%w_]*%b[]%s*" .. def) then
      return true
    end
  end
  return false
end

local function is_header(s)
  return s:match("^fair%+?%s+process%f[%W]") or s:match("^process%f[%W]")
    or s:match("^procedure%f[%W]") or s:match("^macro%f[%W]")
    or s:find("%-%-algorithm%f[%W]") or s:find("%-%-fair%s+algorithm%f[%W]")
end

-- If lnum is inside a PlusCal algorithm, return the `--algorithm` line number.
local function algorithm_start(lnum)
  local stop = math.max(1, lnum - MAX_SCAN)
  for j = lnum - 1, stop, -1 do
    local s = strip(j)
    if s:find("%-%-algorithm%f[%W]") or s:find("%-%-fair%s+algorithm%f[%W]") then
      return j
    end
    if s:find("%*%)") or s:match("^end%s+algorithm") or s:find("BEGIN TRANSLATION") then
      return nil
    end
  end
  return nil
end

-- Walk back from lnum to the line that opens the block lnum sits in.
-- Returns that line number, or nil.
local function enclosing_opener(lnum, stop)
  local depth = 0
  for j = lnum - 1, math.max(stop or 1, lnum - MAX_SCAN), -1 do
    local s = strip(j)
    if s ~= "" then
      local c, o = is_closer(s), is_opener(s)
      if c and o then -- else / or / elsif … then / } else {: mid-block
        if depth == 0 then return j end
      elseif c then
        depth = depth + 1
      elseif o then
        if depth == 0 then return j end
        depth = depth - 1
      end
    end
  end
  return nil
end

-- Where should a label on lnum go? Line up with the previous label in the
-- same block, or one level inside the block if it's the first.
local function label_indent(lnum, sw)
  local depth = 0
  for j = lnum - 1, math.max(1, lnum - MAX_SCAN), -1 do
    local s = strip(j)
    if s ~= "" then
      local c, o = is_closer(s), is_opener(s)
      if c and o then
        if depth == 0 then return vim.fn.indent(j) + sw end
      elseif c then
        depth = depth + 1
      elseif o then
        if depth == 0 then return vim.fn.indent(j) + sw end
        depth = depth - 1
        -- `Lbl: while x do … end while;` — the label itself is a sibling
        if depth == 0 and is_label(s) then return vim.fn.indent(j) end
      elseif depth == 0 and is_label(s) then
        return vim.fn.indent(j)
      end
    end
  end
  return -1
end

local function starts_junction(s)
  return s:match("^/\\") or s:match("^\\/") or s:match("^∧") or s:match("^∨")
end

-- While typing a new definition, is it inside a LET (so it shouldn't snap)?
local function inside_let(lnum, level, top)
  local ins = 0
  for j = lnum - 1, math.max(top, lnum - 200), -1 do
    local s = strip(j)
    if s:match("^IN%f[%W]") then ins = ins + 1 end
    for _ in s:gmatch("%f[%w]LET%f[%W]") do
      if ins > 0 then ins = ins - 1 else return true end
    end
    if is_definition(s) and vim.fn.indent(j) == level then return false end
  end
  return false
end

-- Plain TLA+: help on new lines and as you type, but never reflow existing
-- text with = or gg=G (returning -1 keeps the current indent).
--   level: column where definitions go (0 at top level, inside define: +sw)
--   top:   don't scan above this line
local function tla_indent(lnum, prev, sw, level, top)
  local cur = vim.fn.getline(lnum):gsub("^%s+", "")
  local raw = vim.fn.getline(prev)
  local typing = vim.fn.mode():sub(1, 1) == "i"

  if cur == "" or starts_junction(cur) then
    -- `Foo == /\ a` → put the next /\ directly under the first one
    for _, def in ipairs({ "==", "≜" }) do
      local _, e = raw:find(def .. "%s*")
      if e and starts_junction(raw:sub(e + 1)) then
        return vim.fn.strdisplaywidth(raw:sub(1, e))
      end
    end
  end

  if cur == "" then
    local p = raw:gsub("\\%*.*$", ""):gsub("%s+$", "")
    if p:match("==$") or p:match("≜$") then return vim.fn.indent(prev) + sw end
  end

  if typing then
    -- Finished typing `Foo ==` at the end of a /\ list: snap back out
    if is_definition(cur) and not inside_let(lnum, level, top) then return level end
    -- ==== / ---- module delimiters
    if level == 0 and (cur:match("^====") or cur:match("^%-%-%-%-")) then return 0 end
  end
  return -1
end

function _G.TlaPlusCalIndent()
  local lnum = vim.v.lnum
  local prev = vim.fn.prevnonblank(lnum - 1)
  if prev == 0 then return 0 end
  local sw = vim.fn.shiftwidth()

  local algo = algorithm_start(lnum)
  if not algo then return tla_indent(lnum, prev, sw, 0, 1) end

  local cur = strip(lnum)

  -- Closers line up with whatever opened the block.
  if is_closer(cur) then
    local j = enclosing_opener(lnum, algo)
    return j and vim.fn.indent(j) or math.max(vim.fn.indent(prev) - sw, 0)
  end

  local opener = enclosing_opener(lnum, algo)

  -- Inside a define block the contents are plain TLA+.
  if opener and strip(opener):match("^define%f[%W]") then
    local level = vim.fn.indent(opener) + sw
    if prev == opener then return level end
    return tla_indent(lnum, prev, sw, level, opener)
  end

  -- define / macro / procedure / process sit at the algorithm's top level:
  -- inside its { in c-syntax, level with `--algorithm` in p-syntax.
  if is_section(cur) then
    return opener and vim.fn.indent(opener) + sw or vim.fn.indent(algo)
  end

  -- `begin` lines up with its process / procedure / macro / algorithm.
  if cur:match("^begin%f[%W]") then
    for j = lnum - 1, algo, -1 do
      if is_header(strip(j)) then return vim.fn.indent(j) end
    end
    return vim.fn.indent(prev)
  end

  if is_label(cur) then
    local ind = label_indent(lnum, sw)
    if ind >= 0 then return ind end
  end

  -- Everything else: relative to the previous line.
  local p = strip(prev)
  local ind = vim.fn.indent(prev)
  if is_opener(p) or is_label_only(p) or p == "variables" then
    ind = ind + sw
  end
  return ind
end

vim.bo.indentexpr = "v:lua.TlaPlusCalIndent()"
-- Re-indent on Enter/o/O and Ctrl-F, and as you finish typing ; : } or a
-- block/section keyword. = is there so `Foo ==` can snap out of a /\ list.
vim.bo.indentkeys = "!^F,o,O,e,;,:,=,0},=or,=elsif,=end,=begin,"
  .. "=define,=macro,=procedure,=process,=fair"
