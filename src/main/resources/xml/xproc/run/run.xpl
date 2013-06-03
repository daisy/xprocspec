<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="px:test-run" name="main" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="true"/>
    <p:option name="depend-on-stored-files" select="''"/>

    <!-- This version of run.xpl depends on Calabash and its cx:eval. Hopefully dynamic evaluation of pipelines will be included in XProc v2. -->

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

    <p:for-each>
        <p:load name="test">
            <p:with-option name="href" select="/*"/>
        </p:load>
        <p:choose>
            <p:when test="/*[self::c:errors]">
                <p:identity/>
            </p:when>
            <p:otherwise>
                <p:try>
                    <p:group>
                        <cx:eval>
                            <p:input port="pipeline">
                                <p:pipe port="result" step="test"/>
                            </p:input>
                            <p:input port="source">
                                <p:empty/>
                            </p:input>
                            <p:input port="options">
                                <p:empty/>
                            </p:input>
                        </cx:eval>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe step="catch" port="error"/>
                            </p:input>
                        </p:identity>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:catch>
                </p:try>
                <p:for-each>
                    <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                    <p:iteration-source select="/calabash-issue-102/*"/>
                    <p:identity/>
                </p:for-each>
            </p:otherwise>
        </p:choose>
    </p:for-each>

</p:declare-step>
