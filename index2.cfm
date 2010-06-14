<cfscript>
//microbenchmark component creation

loopcount=100;
components = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	components[i] = new ChildWithNoInspectorOnInit();
	components[i].setSomeString("hi mom, it's #now()#");
}
totalCreateTS = getTickCount()-startTS;



childOne = new ChildComponent();
childOne.setSomeString("hi mom, it's #now()#");
propertyBooster = new propertyBooster();
result = propertyBooster.inspect(childOne);
writeDump(var=result,expand=false,label="propertyBooster.inspect()");
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	inspectResult = propertyBooster.inspect(object=components[i]);
}
totalInspection = getTickCount()-startTS;


childWithInspectorComponents = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	childWithInspectorComponents[i] = new ChildWithInspectorOnInit();
}
totalInspection2 = getTickCount()-startTS;


childWithInspectorComponents = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	childWithInspectorComponents[i] = new ChildWithInspectorOnInit(propertyBooster=propertyBooster);
}
totalInspection3 = getTickCount()-startTS;


startTS = getTickCount();
persistentProps = {persistent=true};
for(i=1; i LTE loopcount; i++){
	pps = propertyBooster.getPropertiesWithAttributes(childWithInspectorComponents[1],persistentProps);
}
totalGetPersistentProperties = getTickCount()-startTS;


startTS = getTickCount();
persistentNumericProps = {persistent=true,type="numeric"};
for(i=1; i LTE loopcount; i++){
	pnps = propertyBooster.getPropertiesWithAttributes(childWithInspectorComponents[1],persistentNumericProps);
}
totalGetPersistentNumericProperties = getTickCount()-startTS;



</cfscript>


<cfoutput>
#totalCreateTS# ms to create #loopcount# child components

<br>


#totalInspection# ms to create metadata for #loopcount# objects of the same type

<br>

#totalInspection2# ms to create #loopcount# components with inspection on init

<br>

#totalInspection3# ms to create #loopcount# components with inspection on init, passing in the propertyBooster

<br>

#totalGetPersistentProperties# ms to get "persistent" properties for #loopcount# components

<br>

#totalGetPersistentNumericProperties# ms to get "persistent, numeric" properties for #loopcount# components

<br>

<cfdump var="#childWithInspectorComponents[1].getPropertyMetadata()#" expand="false" label="propertyMetadata">

<br>

<cfdump var="#propertyBooster.getCache()#" expand="false" label="propertyBooster cache">

<br>

<cfdump var="#pps#" expand="false" label="Persistent properties">

<br>

<cfdump var="#pnps#" expand="false" label="Persistent, numeric properties">

<!---<cfdump var="#inspector.getProperties()#" expand="false" label="getProperties">
<cfdump var="#inspector.getAnnotations()#" expand="false" label="getAnnotations">
<cfdump var="#getMetadata(components[1])#" expand="false" label="getMetadata">

<cfoutput>
Child mongodb: #childInspector.getAnnotationValue("mongodb")#
<br />
Child variable value: #childInspector.getPropertyValue("SomeString")#
<br />
Child2 variable value: #childInspector2.getPropertyValue("SomeString")#
</cfoutput>
--->

</cfoutput>