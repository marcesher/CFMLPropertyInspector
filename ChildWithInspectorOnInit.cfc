component extends="ChildComponent" accessors="true"{

	function init(propertyBooster=""){
		if(isSimpleValue(arguments.propertyBooster)){
			propertyBooster = new propertyBooster();
		}
		variables.propertyMetadata = propertyBooster.inspect(this);
	}

	function getPropertyMetadata(){
		return variables.propertyMetadata;
	}

}
