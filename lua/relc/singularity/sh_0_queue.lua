local table_remove = table.remove



local _queue_meta = {
	__index = {
		Queue = function(self, val)
			self[#self + 1] = val
		end,

		Dequeue = function(self)
			local val = self[1]

			table_remove(self, 1)

			return val
		end,

		Peek = function(self)
			return self[1]
		end,

		SetHead = function(self, val)
			self[1] = val
		end,

		IsEmpty = function(self)
			return #self == 0
		end,
	}
}



RelC.Queue = function()
	return setmetatable({}, _queue_meta)
end
