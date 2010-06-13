component extends="ChildComponent" accessors="true"{

	function init(propertyHelper=""){
		if(isSimpleValue(arguments.propertyHelper)){
			propertyHelper = new PropertyHelper();
		}
		variables.propertyMetadata = propertyHelper.inspect(this);
	}

	function getPropertyMetadata(){
		return variables.propertyMetadata;
	}

}
