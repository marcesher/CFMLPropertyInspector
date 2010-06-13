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
propertyHelper = new PropertyHelper();
result = propertyHelper.inspect(childOne);
writeDump(result);
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	inspectResult = propertyHelper.inspect(object=components[i]);
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
	childWithInspectorComponents[i] = new ChildWithInspectorOnInit(propertyHelper=propertyHelper);
}
totalInspection3 = getTickCount()-startTS;







</cfscript>


<cfoutput>
#totalCreateTS# ms to create #loopcount# child components

<br>


#totalInspection# ms to create metadata for #loopcount# objects of the same type

<br>

#totalInspection2# ms to create #loopcount# components with inspection on init

<br>

#totalInspection3# ms to create #loopcount# components with inspection on init, passing in the propertyHelper

<br>

<cfdump var="#childWithInspectorComponents[1].getPropertyMetadata()#">

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