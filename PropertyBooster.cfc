<cfscript>
	component accessors="true"{
		property name="cacheStorageScope" type="string" default="request";
		cacheName = "__propertyinspectorcache__";
		cacheStorageScope = "request";



		public function inspect(any object){
			//mix-in a back door to the object under inspection so we can get at its variables
			object._getVariables = this._getVariables;

			//we do this so the getters don't have to look in the cache all the time
			return _getMetadata(object);
		}

		public function getPropertiesWithAttributes(any object, struct KeysAndValues){
			var result = {};
			var md = _getMetadata(object);
			var keyName = keysAndValues.toString();
			var prop = "";
			var key = "";
			var keyValueCount = structCount(keysAndValues);
			if(structKeyExists(md.propertiesWithKeys,keyName)){
				return md.propertiesWithKeys[keyName];
			}
			else{
				var props = md.properties;
				for(prop in props){
					var includeCount=0;
					for(key in keysAndValues){
						if(structKeyExists(props[prop],key) AND props[prop][key] eq KeysAndValues[key]){
							includeCount++;
						}
					}
					if(includeCount eq keyValueCount){
						result[prop] = props[prop];
					}
				}
				md.propertiesWithKeys[keyName] = result;//effectively adds it to the cache
				return result;
			}
		}


		public function getComponentAnnotationValue(any object, string name, any defaultValue=""){
			var md = _getMetadata(object).componentannotations;
			if(structKeyExists(md,name)){
				return md[name];
			}
			return defaultValue;
		}

		private function _getMetadata(any object){
			var md = getMetadata(object);
			var result = getFromCache(md.name);
			if(structIsEmpty(result)){
				result = flattenProperties(object);
				addToCache(md.name,result);
			}
			return result;
		}

		//a function we'll mix in to the object
		public function _getVariables(){
			return variables;
		}

		private struct function flattenProperties(any object){
			var prop = 1;
			var counter = 1;
			var props = {};
			var annotations = {};
			var defaultVariableValues = {};
			var metadata = getMetadata(object);
			var propertyName = "";
			var properties = [];

			while(structKeyExists(metadata,"extends")){
				//get properties
				if(StructKeyExists(metadata,"properties")){
					properties = metadata.properties;
				}
				var propertiesCount = arrayLen(properties);
				for(prop=1; prop <= propertiesCount; prop++){
					propertyName = properties[prop].name;
					if(!structKeyExists(props,propertyName)){
						properties[prop]["_sort_"] = counter;
						props[propertyName] = properties[prop];
						defaultVariableValues[propertyName] = deriveVariableValueFromPropertyDefinition(props[propertyName]);
						counter++;
					}
				}
				//get component annotations
				for(annotation in metadata){
					if(isSimpleValue(metadata[annotation]) AND NOT StructKeyExists(annotations,annotation)){
						annotations[annotation] = metadata[annotation];
					}
				}
				metadata = metadata.extends;
			}
			return {properties=props,componentAnnotations=annotations,defaultVariableValues=defaultVariableValues,propertiesWithKeys={}};
		}


		//don't ask
		private function deriveVariableValueFromPropertyDefinition(propStruct){

			if(NOT structKeyExists(propStruct,"type")){
				propStruct["type"] = "string";
			}
			if(NOT structKeyExists(propStruct,"default")){
				propStruct["default"] = "";
			}

			//initialize variable values
			switch(propStruct.type){
				case "struct":
					if(propStruct.default eq "") return {};
					return deserializeJSON(propStruct.default);
				case "array":
					if(propStruct.default eq "") return [];
					return deserializeJSON(propStruct.default);
				case "date":
					if(NOT isDate(propStruct.default)) return now();
				case "boolean":
					if(NOT isBoolean(propStruct.default)) return true;
				case "numeric":
					if(NOT isNumeric(propStruct.default)) return 0;
			}
			return propStruct.default;
		}


		public function getCache(){
			return structGet("#cacheStorageScope#.#cacheName#");
		}

		public function clearCache(){
			structClear(getCache());
		}

		public function getFromCache(string name){
			var cache = getCache();
			if(structKeyExists(cache,name)){
				return cache[name];
			}
			return {};
		}
		public function addToCache(name,value){
			var cache = getCache();
			cache[name] = value;
			return cache[name];
		}
	}

</cfscript>