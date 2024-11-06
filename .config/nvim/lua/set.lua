---@class Set
---@field elements table<any, boolean>
Set = {}
Set.__index = Set

--- Constructor for creating a new set
---@param initialList table|nil  -- Accepts a table (list) or nil for empty set
---@return Set
function Set:new(initialList)
    local instance = setmetatable({}, self)
    instance.elements = {}

    -- Populate the set with elements from initialList if provided
    if initialList then
        for _, element in ipairs(initialList) do
            instance:add(element)
        end
    end

    return instance
end

--- Add an element to the set
---@param element any
function Set:add(element)
	self.elements[element] = true -- Setting key to true enforces uniqueness
end

--- Remove an element from the set
---@param element any
function Set:remove(element)
	self.elements[element] = nil
end

---Check if the set contains an element
---@param element any
function Set:has(element)
	return self.elements[element] ~= nil
end

---Union operation: combines two sets
---@param otherSet Set
---@return Set
function Set:union(otherSet)
	local resultSet = Set:new()
	for key in pairs(self.elements) do
		resultSet:add(key)
	end
	for key in pairs(otherSet.elements) do
		resultSet:add(key)
	end
	return resultSet
end

-- Intersection operation: elements common to both sets
function Set:intersection(otherSet)
	local resultSet = Set:new()
	for key in pairs(self.elements) do
		if otherSet:contains(key) then
			resultSet:add(key)
		end
	end
	return resultSet
end

-- Difference operation: elements in this set but not in otherSet
---@param otherSet Set
---@return Set
function Set:difference(otherSet)
	local resultSet = Set:new()
	for key in pairs(self.elements) do
		if not otherSet:has(key) then
			resultSet:add(key)
		end
	end
	return resultSet
end

return Set
