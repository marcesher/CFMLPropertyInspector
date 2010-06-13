<cfscript>
	component accessors="true"{
		property name="cacheStorageScope" type="string" default="request";
		cacheName = "__propertyinspectorcache__";
		cacheStorageScope = "request";
		variables.UNDEFINED_PROPERTY_DEFAULT = "__$$UNDEFINED$$__";



		function inspect(any object){
			//mix-in a back door to the object under inspection so we can get at its variables
			object._getVariables = this._getVariables;

			//we do this so the getters don't have to look in the cache all the time
			return _getMetadata(object);
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
			return {properties=props,componentAnnotations=annotations,defaultVariableValues=defaultVariableValues};
		}

		public function getAnnotationValue(any object, string name, boolean errorOnUndefined=true){
			var componentAnnotations = _getMetadata(object).componentAnnotations;
			if(structKeyExists(componentAnnotations,arguments.name)){
				return componentAnnotations[arguments.name];
			}
			if(NOT errorOnUndefined){
				return "";
			}
			throw(type="AnnotationDoesNotExist",message="Component annotation [#arguments.name#] does not exist");
		}

		public function getPropertyValue(any object, string name, boolean errorOnUndefined=true){
			var componentAnnotations = _getMetadata(object).properties;
			var objectVariables = object._getVariables();
			if(structKeyExists(objectVariables,arguments.name)){
				return objectVariables[arguments.name];
			}
			//attempt to get the variable value from the property definition
			var valueFromPropertyDefinition = deriveVariableValueFromPropertyDefinition(arguments.name);
			if(valueFromPropertyDefinition neq UNDEFINED_PROPERTY_DEFAULT){
				return valueFromPropertyDefinition;
			}

			if(NOT errorOnUndefined){
				return "";
			}
			throw(type="PropertyDoesNotExist",message="Property value [#arguments.name#] has not been defined and initialized");
		}

		private boolean function isEmpty(variable){
			if(
				isNull(variable)
				OR ( isArray(variable) and arrayIsEmpty(variable) )
				OR ( isStruct(variable) and structIsEmpty(variable) )
				OR ( isQuery(variable) and variable.recordcount eq 0 )
				OR ( isSimpleValue(variable) and !len(variable) )
			){
				return true;
			}
			return false;
		}

		private function toJavaType(value){
			if(not isNumeric(value) AND isBoolean(value)) return javacast("boolean",value);
			if(isNumeric(value) and find(".",value)) return javacast("double",value);
			if(isNumeric(value)) return javacast("int",value);
			return value;
		}

		//don't ask
		private function deriveVariableValueFromPropertyDefinition(propStruct){
			if(
				NOT structKeyExists(propStruct,"default")
				OR NOT structKeyExists(propStruct,"type")
			){
				return UNDEFINED_PROPERTY_DEFAULT;
			}

			//initialize variable values
			switch(propStruct.type){
				case "struct":
					if(propStruct.default eq "") return {};
					return serializeJSON(propStruct.default);
				case "array":
					if(propStruct.default eq "") return [];
					return serializeJSON(propStruct.default);
				case "date":
					if(NOT isDate(propStruct.default)) return now();
					return propStruct.default;
				case "boolean":
					if(NOT isBoolean(propStruct.default)) return true;
					return propStruct.default;
				case "numeric":
					if(NOT isNumeric(propStruct.default)) return 0;
					return propStruct.default;
				default:
					return propStruct.default;
			}
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