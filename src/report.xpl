<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="j:test-report" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:j="http://josteinaj.no/ns" exclude-inline-prefixes="#all"
    version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" pkg:import-uri="http://josteinaj.no/ns/2013/xprocspec/report.xpl" xmlns:x="http://www.josteinaj.no/ns/xprocspec">

    <p:input port="source" sequence="true"/>
    <p:output port="result" primary="true"/>
    <p:output port="html"/>

    <p:wrap-sequence wrapper="html"/>
    <!-- TODO: create a machine readable report (primary port), and a human readable report (secondary port) -->

</p:declare-step>
