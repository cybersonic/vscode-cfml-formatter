//
component {
    property name="test" type="string";
    property test type="string" attr="val";
    property string test attr=val;

    property name="name" fieldtype="id" generator="uuid";
    property name="name" fieldtype="id" generator="uuid" ormType="string" setter="false";
}
