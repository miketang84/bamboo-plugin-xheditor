module(..., package.seeall)

local urlprefix = 'xheditor'
local pathprefix = '../plugins/xheditor/views/'

local TMPLS = {
	['basic'] = pathprefix + 'textarea.html',
}


--[[
{^ xheditor _tag='xxx',

width=600,
height=300,
tools = 'full','mfull','simple','mini','或自定义值',
css = '自定义css',

^}


--]]
require 'gd'
function guessPhotoFormat(path)
	local im_src = gd.createFromJpeg(path)
	if not im_src then
		im_src = gd.createFromPng(path)
	end
	if not im_src then
		im_src = gd.createFromGif(path)
	end
	
	return im_src
end

function xheditorPhoto(web, req)
	local Image = require 'bamboo.models.image'
	bamboo.registerModel(Image)
	local newfile, result_type = Image:process(web, req, '/xheditor/')
	
	-- 新上传的图片，在process里面，只保存Upload的几个基本属性，在这里，可以计算一下它的宽和高，再手动保存一次
	-- 但要计算宽高就要使用gd库将其读出
	local im_src = guessPhotoFormat(newfile.path)
	local x, y = im_src:sizeXY()
	newfile.width = x
	newfile.height = y
	newfile:save()

	
	if req.ajax then
		-- 让图片选择后立即上传到编辑器中去
        web:json {err="", msg = '!/' + newfile.path}
    end
	
	
end

function main(args, env)
	local tmpl = 'basic'
	bamboo.URLS['/plugin/xheditor/photo/'] = xheditorPhoto
	return View(TMPLS[tmpl]){name=args.name}

end

