<cfscript>
//microbenchmark component creation

loopcount=100;
components = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	components[i] = new ChildComponent();
}
totalCreateTS = getTickCount()-startTS;

startMDTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	md = getMetadata(components[i]);
}
totalMetadataCreateTS = getTickCount()-startMDTS;



/*startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	component = new org.cfcommons.reflection.impl.ComponentClass(object=components[i]);
}
totalReflectionCreateTS = getTickCount()-startTS;
*/
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	inspector = new Inspector(object=components[i]);
}
totalInspectorCreate = getTickCount()-startTS;


childOne = new ChildComponent();
childInspector = new Inspector(childOne);

startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	inspector = new Inspector2(object=components[i]);
}
totalInspector2Create = getTickCount()-startTS;

childTwo = new ChildComponent();
childInspector2 = new Inspector2(childTwo);


</cfscript>


<cfoutput>
#totalCreateTS# ms to create #loopcount# child components

<br>

#totalMetaDataCreateTS# to call getMetadata() on #loopcount# those child components (for reference)

<br>
<!---
#totalReflectionCreateTS# ms to create metadata
<br> --->

#totalInspectorCreate# ms to create metadata
<br />
#totalInspector2Create# ms to create metadata with nonrecursive inspector

<br>

<!---<cfdump var="#inspector.getProperties()#" expand="false" label="getProperties">
<cfdump var="#inspector.getAnnotations()#" expand="false" label="getAnnotations">
<cfdump var="#getMetadata(components[1])#" expand="false" label="getMetadata">
--->
<cfoutput>
Child mongodb: #childInspector.getAnnotationValue("mongodb")#
<br />
Child variable value: #childInspector.getPropertyValue("SomeString")#
<br />
Child2 variable value: #childInspector2.getPropertyValue("SomeString")#
</cfoutput>


</cfoutput>