<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="j:test-evaluate" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:j="http://josteinaj.no/ns" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/evaluate.xpl" xmlns:x="http://www.josteinaj.no/ns/xprocspec">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>

    <p:for-each>
        <!-- TODO: compare /x:description/x:output with /x:description/x:scenario/x:expect -->
        <p:identity/>
    </p:for-each>

</p:declare-step>
