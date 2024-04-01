
		modDefine('pages/home/index', function() {
			var render = function () {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  return _c(
    "ui-view",
    { staticClass: "box" },
    [
      _c(
        "ui-view",
        { staticClass: "home-title", attrs: { bindtap: "tapHandler" } },
        [_c("ui-text", [_vm._v(_vm._s(_vm.text))])],
        1
      ),
      _c(
        "ui-view",
        { staticClass: "home-go-detail", attrs: { bindtap: "goDetail" } },
        [_c("ui-text", [_vm._v("打开详情页")])],
        1
      ),
    ],
    1
  )
}
var staticRenderFns = []
render._withStripped = true


			Page({
				path: 'pages/home/index',
				render: render,
				usingComponents: {},
				scopeId: 'data-v-fBVzUmmnIG'
			});
		})
	
		modDefine('pages/detail/index', function() {
			var render = function () {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  return _c(
    "ui-view",
    { staticClass: "box" },
    [
      _c("ui-view", { staticClass: "button", attrs: { bindtap: "exit" } }, [
        _vm._v(_vm._s(_vm.text)),
      ]),
    ],
    1
  )
}
var staticRenderFns = []
render._withStripped = true


			Page({
				path: 'pages/detail/index',
				render: render,
				usingComponents: {},
				scopeId: 'data-v-MVYlebrU3H'
			});
		})
	