local oop = require("oop")

----------------------------------------------------------------
----------------- Binary Tree Helper Functions -----------------
----------------------------------------------------------------
local function minTree(node)
  local n = node
  
  if n ~= nil then
    while n.left ~= nil do
      n = n.left
    end
  end
  
  return n
end

local function maxTree(node)
  local n = node
  
  if n ~= nil then
    while n.right ~= nil do
      n = n.right
    end
  end
  
  return n
end
----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------

local Node = oop.class()

function Node:__ctor(key, value, tree, parent)  
  self.key = key
  self.value = value
  self.tree = tree
  
  if parent then
    self.parent = parent
  end
end

function Node:predecessor()
  if self.left then
    return maxTree(self.left)
  end
  
  local n = self
  local p = self.parent
  
  while (p ~= nil) and (n == p.left) do
    n = p
    p = p.parent
  end
    
  return p
end

function Node:successor()
  if self.right then
    return minTree(self.right)
  end
    
  local n = self
  local p = self.parent
  
  while (p ~= nil) and (n == p.right) do
    n = p
    p = p.parent
  end
    
  return p
end

function Node:isLeaf()
  if (self.left == nil) and (self.right == nil) then
    return true
  end
  
  return false
end

local BinaryTree = oop.class()

function BinaryTree:__ctor(duplicatekeys)  
  if duplicatekeys then
    self.duplicatekeys = duplicatekeys
  else
    self.duplicatekeys = false
  end
end

----------------------------------------------------------------
---------------- Binary Tree Internal Functions ----------------
----------------------------------------------------------------
function BinaryTree:internalDeleteLeafNode(node)
  if node == node.parent.left then
    node.parent.left = nil -- Delete Left Parent Node
  else
    node.parent.right = nil -- Delete Right Parent Node
  end
end

function BinaryTree:internalDeleteSingleChildNode(node, replace)
  local p = node.parent
  
  if node == node.parent.left then
    node.parent.left = replace
    node.parent.left.parent = p
  else
    node.parent.right = replace
    node.parent.right.parent = p
  end
end

function BinaryTree:internalDelete(node, key)
  if node == nil then
    return
  end
  
  if key < node.key then
    self:internalDelete(node.left, key)
  elseif key > node.key then
    self:internalDelete(node.right, key)
  else -- if key == node.key then
    if node:isLeaf() then
	self:internalDeleteLeafNode(node) -- Delete Node
    elseif (node.left == nil) or (node.right == nil) then -- 1 Child Node    
      if node.right then
	self:internalDeleteSingleChildNode(node, node.right) -- Delete Node
      else
	self:internalDeleteSingleChildNode(node, node.left) -- Delete Node
      end
    else -- 2 Children Node
      local succnode = node:successor()      
      node.key = succnode.key     -- Copy Successor's Key/Value
      node.value = succnode.value -- Copy Successor's Key/Value
      
      self:internalDelete(succnode, succnode.key) -- Delete Successor
    end
  end
end

function BinaryTree:internalInsert(node, key, value)  
  if (self.duplicatekeys == false) and (key == node.key) then -- Avoid Duplicate Keys (if set)
    return
  elseif key < node.key then -- Insert Left
    if node.left == nil then
      node.left = Node(key, value, self, node)
    else
      self:internalInsert(node.left, key, value)
    end
  else -- Insert Right
    if node.right == nil then
      node.right = Node(key, value, self, node)
    else
      self:internalInsert(node.right, key, value)
    end
  end
end

function BinaryTree:internalFind(node, key)
  if (node == nil) or (key == node.key) then
    return node
  elseif key < node.key then
    return self:internalFind(node.left, key)
  else -- if key > node.key then
    return self:internalFind(node.right, key)
  end
  
  return nil
end

function BinaryTree:internalTraverseInOrder(node, callback, param)
  if node == nil then
    return
  end
  
  self:internalTraverseInOrder(node.left, callback, param)
  callback(node, param)
  self:internalTraverseInOrder(node.right, callback, param)
end
----------------------------------------------------------------

function BinaryTree:insert(key, value)
  if self.root == nil then
    self.root = Node(key, value, self)
  else
    self:internalInsert(self.root, key, value)
  end
end

function BinaryTree:delete(key)
  self:internalDelete(self.root, key)
end

function BinaryTree:find(key)
  return self:internalFind(self.root, key)
end

function BinaryTree:traverseInOrder(callback, param)
  self:internalTraverseInOrder(self.root, callback, param)
end

function BinaryTree:min()
  return minTree(self.root)
end

function BinaryTree:max()
  return maxTree(self.root)
end

return BinaryTree