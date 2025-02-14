local LargeNum = {}
--[[
LargeNum is a big number library that allows you to go beyond Lua’s native limits.
Suitable for incrementals.
Feel free to use this module.
]]
-- Function to create a new LargeNum object with mantissa, exponent, and sign
function LargeNum.New(mantissa, exponent, sign)
    -- Normalize the mantissa and exponent
    if mantissa == 0 then
        return {mantissa = 0, exponent = 0, sign = 1}  -- Zero is always positive
    end

    -- Handle sign (1 = positive, -1 = negative)
    if mantissa < 0 then
        sign = -1
        mantissa = -mantissa
    else
        sign = 1
    end

    -- Normalize the mantissa and exponent
    while math.abs(mantissa) >= 10 do
        mantissa = mantissa / 10
        exponent = exponent + 1
    end

    while math.abs(mantissa) < 1 and mantissa ~= 0 do
        mantissa = mantissa * 10
        exponent = exponent - 1
    end

    -- Create the object and set the metatable for __index functionality
    local obj = {mantissa = mantissa, exponent = exponent, sign = sign}
    setmetatable(obj, {__index = LargeNum})
    return obj
end

-- Function to remove trailing zeros from a string
local function removeTrailingZeros(str)
    return str:gsub("%.?0+$", "")  -- Remove decimal point and trailing zeros
end

-- Function to convert mantissa and exponent into scientific or standard notation
function LargeNum:toString()
    -- Handle the base case where the mantissa is 0
    if self.mantissa == 0 then
        return "0"
    end

    local mantissa, exponent, sign = self.mantissa, self.exponent, self.sign

    -- Check if the exponent falls in the standard range
    if exponent >= -4 and exponent < 12 then
        -- Return the number in standard form with the correct sign
        local result = string.format("%.12g", self.sign *( mantissa * 10 ^ exponent))
        return result  -- Remove trailing zeros
    end
    -- Construct the scientific notation with the correct sign
    local sign_str = sign == -1 and "-" or ""
    local exp_sign = exponent >= 0 and "+" or "-"
    local result = string.format("%s%.11gE%s%d", sign_str, mantissa, exp_sign, math.abs(exponent))
    return result  -- Remove trailing zeros
end

-- Arithmetic operations using mantissa, exponent, and sign
function LargeNum.add(a, b)
    -- Align exponents for addition and subtraction
    local exp = math.max(a.exponent, b.exponent)
    local mantissa_a = a.mantissa * 10^(a.exponent - exp)
    local mantissa_b = b.mantissa * 10^(b.exponent - exp)

    -- Adjust signs based on addition or subtraction
    local mantissa = (a.sign == b.sign) and (mantissa_a + mantissa_b) or (mantissa_a - mantissa_b)
    local sign = mantissa < 0 and -1 or 1
    mantissa = math.abs(mantissa)

    return LargeNum.New(mantissa, exp, sign)
end

function LargeNum.subtract(a, b)
    -- Align exponents for addition and subtraction
    local exp = math.max(a.exponent, b.exponent)
    local mantissa_a = a.mantissa * 10^(a.exponent - exp)
    local mantissa_b = b.mantissa * 10^(b.exponent - exp)

    -- Adjust signs based on subtraction
    local mantissa = (a.sign == b.sign) and (mantissa_a - mantissa_b) or (mantissa_a + mantissa_b)
    local sign = mantissa < 0 and -1 or 1
    mantissa = math.abs(mantissa)

    return LargeNum.New(mantissa, exp, sign)
end

function LargeNum.multiply(a, b)
    local mantissa = a.mantissa * b.mantissa
    local exponent = a.exponent + b.exponent
    local sign = a.sign * b.sign  -- The sign is the product of the two signs
    return LargeNum.New(mantissa, exponent, sign)
end

function LargeNum.divide(a, b)
    if b.mantissa == 0 then
        error("Division by zero is not allowed.")
    end
    local mantissa = a.mantissa / b.mantissa
    local exponent = a.exponent - b.exponent
    local sign = a.sign * b.sign  -- The sign is the product of the two signs
    return LargeNum.New(mantissa, exponent, sign)
end

-- __index metamethod to access properties directly
function LargeNum.__index(obj, key)
    if key == "mantissa" then
        return obj.mantissa
    elseif key == "exponent" then
        return obj.exponent
    elseif key == "sign" then
        return obj.sign
    else
        return nil  -- Return nil for unknown keys
    end
end

return LargeNum
