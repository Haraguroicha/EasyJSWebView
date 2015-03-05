//  Modified by 腹黒い茶 on 2/3/2015.
window.EasyJS = {
	__callbacks: {},
	
	invokeCallback: function (cbID, removeAfterExecute) {
		var args = Array.prototype.slice.call(arguments);
		args.shift();
		args.shift();
		
		for (var i = 0, l = args.length; i < l; i++) {
			args[i] = JSON.parse(args[i]);
		}
		
		var cb = EasyJS.__callbacks[cbID];
		if (removeAfterExecute){
			EasyJS.__callbacks[cbID] = undefined;
            delete EasyJS.__callbacks[cbID];
		}
		return cb.apply(null, args);
	},
	
	call: function (obj, functionName, args) {
		var formattedArgs = [];
		for (var i = 0, l = args.length; i < l; i++) {
			if (typeof args[i] == "function") {
				formattedArgs.push("f");
				var cbID = "__cb" + (+new Date);
				EasyJS.__callbacks[cbID] = args[i];
				formattedArgs.push(cbID);
			} else {
				formattedArgs.push("s");
				formattedArgs.push(encodeURIComponent(JSON.stringify(args[i])));
			}
		}
		
		var argStr = (formattedArgs.length > 0 ? ":" + encodeURIComponent(formattedArgs.join(":")) : "");

        var methodInfo = obj + ":" + encodeURIComponent(functionName) + argStr;
        var xhr = new XMLHttpRequest();
        xhr.open('POST', window.__nativeURL, false);
        xhr.setRequestHeader("X-Method-Info", methodInfo);
        xhr.send(methodInfo);
        if (xhr.status === 200) {
            window.__returnedValue = xhr.responseText;
            if (window.__returnedValue == "") window.__returnedValue = null;
        } else {
            console.log(xhr);
        }

        var retValue = JSON.parse(JSON.stringify([ { value: decodeURIComponent(window.__returnedValue) } ]))[0].value;
        if (retValue == 'false' || retValue == 'true' || retValue == 'null') retValue = JSON.parse(retValue);
        console.log(retValue);
        delete window.__returnedValue;
        return retValue;
	},
	
	inject: function (obj, methods) {
		window[obj] = {};
		var jsObj = window[obj];
		
		for (var i = 0, l = methods.length; i < l; i++) {
			(function () {
				var method = methods[i];
				var jsMethod = method.replace(new RegExp(":", "g"), "");
				jsObj[jsMethod] = function () {
					return EasyJS.call(obj, method, Array.prototype.slice.call(arguments));
				};
			})();
		}
	}
};
