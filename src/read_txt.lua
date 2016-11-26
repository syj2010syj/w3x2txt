local tonumber = tonumber

local current_chunk

local function convert(str)
    if str:sub(1, 6) == '\x22\xAD\xA6\xE4\xB9\xA0' then
        str = '\xE5' .. str:sub(2)
    end
    return str
end

local function parse(txt, line)
    if #line == 0 then
        return
    end
    if line:sub(1, 2) == '//' then
        return
    end
    local chunk_name = line:match '^[%c%s]*%[(.-)%][%c%s]*$'
    if chunk_name then
        current_chunk = chunk_name
        if not txt[chunk_name] then
            txt[chunk_name] = {}
        end
        return
    end
    if not current_chunk then
        return
    end
    line = line:gsub('%c+', '')
    local key, value = line:match '^(.*)%=(.-)%s*$'
    if key and value then
        txt[current_chunk][key] = convert(value)
        return
    end
end

return function (content)
	if not content then
		return
	end
    current_chunk = nil
    local txt = {}
	for line in content:gmatch '[^\r\n]+' do
        parse(txt, line)
    end
    return txt
end
