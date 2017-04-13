local robot = require('robot');
local tcp = require('tcp');
local orient = require('trackOrientation');
local config = require('config');

-- don't stop using these functions once you start or they won't be accurate
local position = config.get("pos.txt");
if not (position.x and position.y and position.z) then
  local position = {x=0, y=0, z=0}; -- fix this
end

local M = {};

function M.set(x, y, z)
  position = {x=x, y=y, z=z};
  return position;
end

function M.get()
  return position;
end

-- how to change coordinates based on orientation
-- 0: z+, south
-- 1: x+, east
-- 2: z-, north
-- 3: x-, west
local forwardMap = {
  [0]={z=1},
  [1]={x=1},
  [2]={z=-1},
  [3]={x=-1}
};

local backwardMap = {
  [0]={z=-1},
  [1]={x=-1},
  [2]={z=1},
  [3]={x=1}
};


function M.sendLocation()
  return tcp.write({['robot position']=position});
end

-- orientation comes from trackOrientation.lua
function M.forward()
  -- the loop will only perform one iteration
  -- this is just a way to treat the properties generically
  if (robot.forward()) then
    for axis, change in pairs(forwardMap[orient.get()]) do
      position[axis] = position[axis] + change;
    end
    M.sendLocation();
    return position;
  end
  -- if the movement failed
  return false;
end

function M.back()
  if (robot.back()) then
    for axis, change in pairs(backwardMap[orient.get()]) do
      position[axis] = position[axis] + change;
    end
    M.sendLocation();
    return position;
  end
  return false;
end

function M.up()
  if (robot.up()) then
    position.y = position.y + 1;
    M.sendLocation();
    return position;
  end
  return false;
end

function M.down()
  if (robot.down()) then
    position.y = position.y - 1;
    M.sendLocation();
    return position;
  end
  return false;
end

return M;
