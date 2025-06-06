local _, NS = ...

local type = type
local next = next
local pairs = pairs
local ipairs = ipairs
local getmetatable = getmetatable
local setmetatable = setmetatable

NS.isNPCInList = function(list, npcID)
  for _, id in ipairs(list) do
    if id == npcID then
      return true
    end
  end
  return false
end

-- Copies table values from src to dst if they don't exist in dst
NS.CopyDefaults = function(src, dst)
  if type(src) ~= "table" then
    return {}
  end

  if type(dst) ~= "table" then
    dst = {}
  end

  for k, v in pairs(src) do
    if type(v) == "table" then
      if k == "cvars" then
        if not dst[k] or next(dst[k]) == nil then
          dst[k] = NS.CopyDefaults(v, dst[k])
        end
      else
        dst[k] = NS.CopyDefaults(v, dst[k])
      end
    elseif type(v) ~= type(dst[k]) then
      dst[k] = v
    end
  end

  return dst
end

NS.CopyTable = function(src, dest)
  -- Handle non-tables and previously-seen tables.
  if type(src) ~= "table" then
    return src
  end

  if dest and dest[src] then
    return dest[src]
  end

  -- New table; mark it as seen an copy recursively.
  local s = dest or {}
  local res = {}
  s[src] = res

  for k, v in next, src do
    res[NS.CopyTable(k, s)] = NS.CopyTable(v, s)
  end

  return setmetatable(res, getmetatable(src))
end

-- Cleanup savedvariables by removing table values in src that no longer
-- exists in table dst (default settings)
NS.CleanupDB = function(src, dst)
  for key, value in pairs(src) do
    if dst[key] == nil then
      -- HACK: offsetsXY are not set in DEFAULT_SETTINGS but sat on demand instead to save memory,
      -- which causes nil comparison to always be true here, so always ignore these for now
      if key ~= "version" then
        src[key] = nil
      end
    elseif type(value) == "table" then
      if key ~= "cvars" then -- also set on demand
        dst[key] = NS.CleanupDB(value, dst[key])
      end
    end
  end
  return dst
end
