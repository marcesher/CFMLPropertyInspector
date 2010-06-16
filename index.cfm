<cfscript>
/* basic usage #1: you need to do stuff with components you don't necessarily control (i.e. you have a framework or other API you're applying to other code) */

//this is how you use the propertybooster to inspect a component and get lots of data; all of this data is cached in the request scope,
//so subsequent inspections of different objects of the same time will return the same inspection results
childOne = new ChildComponent();
childOne.setSomeString("hi mom, it's #now()#");
propertyBooster = new propertyBooster();
result = propertyBooster.inspect(childOne);

writeDump(var=result,expand=false,label="propertyBooster.inspect()");



/* basic usage #2: you are writing code and you want to use properties to drive the variables, but don't want to duplicate the effort */
//a normal, metadata-only component. dump its variables on init
childWithNoInspectorOnInit = new childWithNoInspectorOnInit();
writeDump(var=childWithNoInspectorOnInit.getVariables(),expand="false",label="your normal metadata-only component's variables, after init()");


//a "boosted" component that uses an internal PropertyBooster to copy the property defaults into the variables scope on init so that you don't have to write duplicate code
childWithInspectorOnInit = new childWithInspectorOnInit();
writeDump(var=childWithInspectorOnInit.getVariables(),expand="false",label="supercharged component's variables, after init()");



/*microbenchmark component creation */

loopcount=100;
components = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	components[i] = new ChildWithNoInspectorOnInit();
	components[i].setSomeString("hi mom, it's #now()#");
}
totalCreateTS = getTickCount()-startTS;






//notice how fast this is
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	inspectResult = propertyBooster.inspect(object=components[i]);
}
totalInspection = getTickCount()-startTS;


//this is the bread-n-butter scenario: have a component that uses propertybooster to automatically initialize variables based on property definitions;
//look at ChildWithInspectorOnInit for how this is done in 2 lines of code
childWithInspectorComponents = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	childWithInspectorComponents[i] = new ChildWithInspectorOnInit();
}
totalInspection2 = getTickCount()-startTS;


//let's see what the difference is if we create a propertybooster and pass it in instead of letting the component create a new booster every time
childWithInspectorComponents = [];
startTS = getTickCount();
for(i=1; i LTE loopcount; i++){
	childWithInspectorComponents[i] = new ChildWithInspectorOnInit(propertyBooster=propertyBooster);
}
totalInspection3 = getTickCount()-startTS;

//show how to use the booster's getPropertiesWithAttributes to get properties containing a certain attribute/value combination
startTS = getTickCount();
persistentProps = {persistent=true};
for(i=1; i LTE loopcount; i++){
	pps = propertyBooster.getPropertiesWithAttributes(childWithInspectorComponents[1],persistentProps);
}
totalGetPersistentProperties = getTickCount()-startTS;

//show how to use booster's getPropertiesWithAttributes to show multiple attribute/value combinations. This is an "AND", not an "OR"
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

<!--- uncomment these to see data... notice how adding dumps onto the page slows down everything else about the page? I noticed that
<cfdump var="#childWithInspectorComponents[1].getPropertyMetadata()#" expand="false" label="propertyMetadata">

<br>

<cfdump var="#propertyBooster.getCache()#" expand="false" label="propertyBooster cache">

<br>

<cfdump var="#pps#" expand="false" label="Persistent properties">

<br>

<cfdump var="#pnps#" expand="false" label="Persistent, numeric properties">

 --->


</cfoutput>