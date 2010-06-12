<cfscript>
component accessors="true" mongodb="somedb" mongocollection="yeehaw" {
	property name="SomeString" default="" type="text" persistent="true" editable="true";
	property name="SomeDate" default="" type="date" persistent="true" editable="true";
	property name="SomeNumber" default="0" type="numeric" persistent="false" hidehint="true" editable="true";
	property name="SomeBoolean" default="true" type="text" persistent="true" editable="true";
	property name="SomeComponent" default="" type="ComposedComponent" persistent="true" editable="false";
	property name="SomeStruct" default="" type="struct" persistent="true" editable="false";
	property name="SomeArray" default="" type="array" persistent="true" editable="false";
}
</cfscript>