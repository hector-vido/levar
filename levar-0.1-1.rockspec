package = "levar"
version = "0.1-1"
source = {
   url = ""
}
description = {
   homepage = "",
   license = ""
}
dependencies = {
	'inspect',
	'lapis'
}
build = {
   type = "builtin",
   modules = {
      app = "app.lua",
      config = "config.lua"
   }
}
