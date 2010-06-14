<cfscript>
	component accessors="true"{
		property name="cacheStorageScope" type="string" default="request";
		cacheName = "__propertyinspectorcache__";
		cacheStorageScope = "request";

		function init(any object, errorOnUndefined="false"){
			variables.UNDEFINED_PROPERTY_DEFAULT = "__$$UNDEFINED$$__";
			structAppend(variables,arguments);

			//we do this so the getters don't have to look in the cache all the time
			structAppend(variables, _getMetadata());

			//mix-in a back door to the object under inspection so we can get at its variables
			object._getVariables = this._getVariables;
			variables.objectVariables = object._getVariables();
		}

		private function _getMetadata(){
			var md = getMetadata(variables.object);
			var result = getFromCache(md.name);
			if(structIsEmpty(result)){
				result = flattenProperties();
				addToCache(md.name,result);
			}
			return result;
		}

		//a function we'll mix in to the object
		public function _getVariables(){
			return variables;
		}

		private struct function flattenProperties(){
			var prop = 1;
			var counter = 1;
			var props = {};
			var annotations = {};
			var metadata = getMetadata(variables.object);
			var arguments.name = "";
			var properties = [];
			if(StructKeyExists(metadata,"properties")){
				properties = metadata.properties;
			}
			while(structKeyExists(metadata,"extends")){
				//get properties
				var propertiesCount = arrayLen(properties);
				for(prop=1; prop <= propertiesCount; prop++){
					arguments.name = properties[prop].name;
					if(!structKeyExists(props,arguments.name)){
						properties[prop]["_sort_"] = counter;
						props[arguments.name] = properties[prop];
						counter++;
					}
				}
				//get component annotations
				for(annotation in metadata){
					if(NOT StructKeyExists(annotations,annotation)){
						annotations[annotation] = metadata[annotation];
					}
				}
				metadata = metadata.extends;
			}
			return {properties=props,componentAnnotations=annotations};
		}

		public struct function getProperties(){
			return variables.flattenedProperties;
		}

		public struct function getAnnotations(){
			return variables.componentAnnotations;
		}

		public function getAnnotationValue(string name){
			if(structKeyExists(variables.componentAnnotations,arguments.name)){
				return variables.componentAnnotations[arguments.name];
			}
			if(NOT variables.errorOnUndefined){
				return "";
			}
			throw(type="AnnotationDoesNotExist",message="Component annotation [#arguments.name#] does not exist");
		}

		public function getPropertyValue(string name){

			if(structKeyExists(variables.objectVariables,arguments.name)){
				return variables.objectVariables[arguments.name];
			}
			//attempt to get the variable value from the property definition
			var valueFromPropertyDefinition = deriveVariableValueFromPropertyDefinition(arguments.name);
			if(valueFromPropertyDefinition neq UNDEFINED_PROPERTY_DEFAULT){
				return valueFromPropertyDefinition;
			}

			if(NOT variables.errorOnUndefined){
				return "";
			}
			throw(type="PropertyDoesNotExist",message="Property value [#arguments.name#] has not been defined and initialized");
		}

		public function getInspectedVariables(){
			return variables.objectVariables();
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
		private function deriveVariableValueFromPropertyDefinition(name){
			if(
				NOT structKeyExists(flattenedProperties,"default")
				OR NOT structKeyExists(flattenedProperties,"type")
			){
				return UNDEFINED_PROPERTY_DEFAULT;
			}

			if(!structKeyExists(variables.objectVariables,arguments.name)){
				objectVariables[arguments.name] = "";
			}

			//initialize variable values
			switch(flattenedProperties[arguments.name].type){
				case "struct":
					if(!isStruct(objectVariables[arguments.name])) objectVariables[arguments.name] = {};
					break;
				case "array":
					if(!isArray(objectVariables[arguments.name])){
						if(structKeyExists(flattenedProperties[arguments.name],"default")){
							objectVariables[arguments.name] = deserializeJSON(flattenedProperties[arguments.name]["default"]);
						}else{
							objectVariables[arguments.name] = [];
						}
					}
					break;
				case "date":
					if(!isDate(objectVariables[arguments.name])) objectVariables[arguments.name] = now();
					break;
				case "boolean":
					if(!isBoolean(objectVariables[arguments.name])) objectVariables[arguments.name] = toJavaType(flattenedProperties[arguments.name]["default"]);
					break;
				case "numeric":
					if(!isNumeric(objectVariables[arguments.name])) objectVariables[arguments.name] = toJavaType(flattenedProperties[arguments.name]["default"]);
					break;
				default:
					objectVariables[arguments.name] = toJavaType(flattenedProperties[arguments.name]["default"]);
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