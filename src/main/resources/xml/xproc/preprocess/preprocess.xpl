<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" type="pxi:test-preprocess" xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:c="http://www.w3.org/ns/xproc-step" xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc-internal/xprocspec"
    exclude-inline-prefixes="#all" version="1.0" xpath-version="2.0" xmlns:t="http://xproc.org/ns/testsuite" xmlns:pkg="http://expath.org/ns/pkg" xmlns:x="http://www.daisy.org/ns/pipeline/xproc/test">

    <p:input port="source"/>
    <p:output port="result" sequence="true">
        <p:pipe port="result" step="result"/>
    </p:output>

    <p:option name="temp-dir" required="true"/>

    <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="../utils/logging-library.xpl"/>

    <p:declare-step type="pxi:debug">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:identity/>
    </p:declare-step>

    <p:declare-step type="pxi:perform-imports" name="perform-imports">
        <p:input port="source"/>
        <p:output port="result"/>
        <pxi:message message=" * checking $1 for imports">
            <p:with-option name="param1" select="base-uri(/*)"/>
        </pxi:message>
        <p:viewport match="/*/x:import">
            <p:variable name="import-href" select="resolve-uri(/*/@href,base-uri(/*))"/>
            <pxi:message message=" * importing $1">
                <p:with-option name="param1" select="$import-href"/>
            </pxi:message>
            <p:load>
                <p:with-option name="href" select="$import-href"/>
            </p:load>
            <!-- TODO: validate loaded grammar -->
            <pxi:perform-imports/>
            <p:for-each>
                <p:iteration-source select="/*/x:scenario"/>
                <p:identity/>
            </p:for-each>
        </p:viewport>
    </p:declare-step>

    <p:variable name="test-base-uri" select="base-uri(/*)"/>

    <!-- transform other test vocabularies to xprocspec -->
    <p:choose>
        <p:when test="/*/namespace-uri()='http://www.daisy.org/ns/pipeline/xproc/test'">
            <p:output port="result" primary="true" sequence="true"/>

            <!-- if xprocspec grammar is used in the input document; validate it -->
            <p:identity name="try.input"/>
            <p:try>
                <p:group>
                    <p:validate-with-relax-ng>
                        <p:input port="schema">
                            <p:document href="../../schema/xprocspec.rng"/>
                        </p:input>
                    </p:validate-with-relax-ng>
                    <p:wrap-sequence wrapper="calabash-issue-102"/>
                </p:group>
                <p:catch name="catch">
                    <p:identity>
                        <p:input port="source">
                            <p:pipe port="error" step="catch"/>
                        </p:input>
                    </p:identity>
                    <pxi:message message=" * xprocspec grammar is not valid: $1">
                        <p:with-option name="param1" select="$test-base-uri"/>
                    </pxi:message>
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="$test-base-uri"/>
                    </p:add-attribute>
                    <p:add-attribute match="/*" attribute-name="error-location" attribute-value="preprocess.xpl - input document validation"/>

                    <p:identity name="errors-without-was"/>
                    <p:wrap-sequence wrapper="x:was">
                        <p:input port="source">
                            <p:pipe port="result" step="try.input"/>
                        </p:input>
                    </p:wrap-sequence>
                    <p:add-attribute match="/*" attribute-name="xml:base">
                        <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                    </p:add-attribute>
                    <p:wrap-sequence wrapper="c:error"/>
                    <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                    <p:identity name="was"/>
                    <p:insert match="/*" position="last-child">
                        <p:input port="source">
                            <p:pipe port="result" step="errors-without-was"/>
                        </p:input>
                        <p:input port="insertion">
                            <p:pipe port="result" step="was"/>
                        </p:input>
                    </p:insert>

                    <p:wrap-sequence wrapper="calabash-issue-102"/>
                </p:catch>
            </p:try>
            <p:for-each>
                <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                <p:iteration-source select="/calabash-issue-102/*"/>
                <p:identity/>
            </p:for-each>

            <p:add-attribute match="/*" attribute-name="test-grammar" attribute-value="xprocspec"/>
        </p:when>
        <p:when test="/*/namespace-uri()='http://xproc.org/ns/testsuite'">
            <p:output port="result" primary="true" sequence="true"/>
            <p:variable name="href" select="concat($temp-dir,replace(replace(base-uri(/*),'^.*/([^/]*)$','$1'),'\.[^\.]*',''),'.xpl')"/>
            <pxi:message message=" * input grammar is XProc Test Suite"/>
            <p:choose>
                <p:when test="/t:test-suite">
                    <p:output port="result" primary="true" sequence="true"/>
                    <p:for-each>
                        <p:iteration-source select="/t:test-suite/t:test"/>
                        <p:variable name="href" select="resolve-uri(/*/@href,base-uri())"/>
                        <p:add-attribute match="/*" attribute-name="error-location" attribute-value="xproc-test-suite-load-tests"/>

                        <p:identity name="load-test-suite"/>
                        <p:try>
                            <p:group>
                                <p:load>
                                    <p:with-option name="href" select="$href"/>
                                </p:load>
                                <p:delete match="/*/@error-location"/>
                                <p:wrap-sequence wrapper="calabash-issue-102"/>
                            </p:group>
                            <p:catch name="catch">
                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="error" step="catch"/>
                                    </p:input>
                                </p:identity>
                                <pxi:message message="An error occured while reading XProc Test Suite test: $1">
                                    <p:with-option name="param1" select="$href"/>
                                </pxi:message>
                                <p:add-attribute match="/*" attribute-name="xml:base">
                                    <p:with-option name="attribute-value" select="$href"/>
                                </p:add-attribute>
                                <p:add-attribute match="/*" attribute-name="error-location" attribute-value="preprocess.xpl - loading t:test-suite"/>

                                <p:identity name="errors-without-was"/>
                                <p:wrap-sequence wrapper="x:was">
                                    <p:input port="source">
                                        <p:pipe port="result" step="load-test-suite"/>
                                    </p:input>
                                </p:wrap-sequence>
                                <p:add-attribute match="/*" attribute-name="xml:base">
                                    <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                                </p:add-attribute>
                                <p:wrap-sequence wrapper="c:error"/>
                                <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                                <p:identity name="was"/>
                                <p:insert match="/*" position="last-child">
                                    <p:input port="source">
                                        <p:pipe port="result" step="errors-without-was"/>
                                    </p:input>
                                    <p:input port="insertion">
                                        <p:pipe port="result" step="was"/>
                                    </p:input>
                                </p:insert>

                                <p:wrap-sequence wrapper="calabash-issue-102"/>
                            </p:catch>
                        </p:try>
                        <p:for-each>
                            <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                            <p:iteration-source select="/calabash-issue-102/*"/>
                            <p:identity/>
                        </p:for-each>
                        <p:add-attribute match="/*" attribute-name="test-uri">
                            <p:with-option name="attribute-value" select="$href"/>
                        </p:add-attribute>
                    </p:for-each>
                </p:when>
                <p:otherwise>
                    <p:output port="result" primary="true" sequence="true"/>
                    <p:add-attribute match="/*" attribute-name="test-uri">
                        <p:with-option name="attribute-value" select="$href"/>
                    </p:add-attribute>
                </p:otherwise>
            </p:choose>
            <p:for-each>
                <p:identity name="try.input"/>
                <p:try>
                    <p:group>
                        <p:choose>
                            <p:when test="/*[self::c:errors]">
                                <pxi:message message=" * error document; skipping"/>
                                <p:identity/>
                            </p:when>
                            <p:otherwise>
                                <p:variable name="href" select="concat($temp-dir,replace(replace(base-uri(/*),'^.*/([^/]*)$','$1'),'\.[^\.]*',''),'.xpl')"/>
                                <p:viewport match="t:pipeline//*[@href and not(@href='')] | t:compare-pipeline//*[@href and not(@href='')]">
                                    <p:add-attribute match="/*" attribute-name="href">
                                        <p:with-option name="attribute-value" select="resolve-uri(/*/@href,base-uri(/*))"/>
                                    </p:add-attribute>
                                </p:viewport>
                                <pxi:message message=" * converting grammar from xproc test suite to xprocspec"/>
                                <p:xslt>
                                    <p:input port="parameters">
                                        <p:empty/>
                                    </p:input>
                                    <p:input port="stylesheet">
                                        <p:document href="xprocTestSuite-to-xprocspec.xsl"/>
                                    </p:input>
                                </p:xslt>
                                <p:add-attribute match="/*" attribute-name="script" name="xproctestsuite">
                                    <p:with-option name="attribute-value" select="$href"/>
                                </p:add-attribute>

                                <pxi:message message=" * storing inlined XProc script"/>
                                <p:store>
                                    <p:input port="source" select="/*/x:script/*"/>
                                    <p:with-option name="href" select="$href"/>
                                </p:store>
                                <p:identity>
                                    <p:input port="source">
                                        <p:pipe port="result" step="xproctestsuite"/>
                                    </p:input>
                                </p:identity>
                                <p:delete match="/*/x:script"/>
                            </p:otherwise>
                        </p:choose>
                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:group>
                    <p:catch name="catch">
                        <p:identity>
                            <p:input port="source">
                                <p:pipe port="error" step="catch"/>
                            </p:input>
                        </p:identity>
                        <pxi:message message=" * an error occured while converting from xproc test suite to xprocspec"/>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="$href"/>
                        </p:add-attribute>
                        <p:add-attribute match="/*" attribute-name="error-location" attribute-value="preprocess.xpl - xproc test suite to xprocspec conversion"/>

                        <p:identity name="errors-without-was"/>
                        <p:wrap-sequence wrapper="x:was">
                            <p:input port="source">
                                <p:pipe port="result" step="try.input"/>
                            </p:input>
                        </p:wrap-sequence>
                        <p:add-attribute match="/*" attribute-name="xml:base">
                            <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                        </p:add-attribute>
                        <p:wrap-sequence wrapper="c:error"/>
                        <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                        <p:identity name="was"/>
                        <p:insert match="/*" position="last-child">
                            <p:input port="source">
                                <p:pipe port="result" step="errors-without-was"/>
                            </p:input>
                            <p:input port="insertion">
                                <p:pipe port="result" step="was"/>
                            </p:input>
                        </p:insert>

                        <p:wrap-sequence wrapper="calabash-issue-102"/>
                    </p:catch>
                </p:try>
                <p:for-each>
                    <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
                    <p:iteration-source select="/calabash-issue-102/*"/>
                    <p:identity/>
                </p:for-each>

                <p:add-attribute match="/*" attribute-name="test-grammar" attribute-value="XProc Test Suite"/>
            </p:for-each>
        </p:when>
        <p:otherwise>
            <p:output port="result" primary="true" sequence="true"/>
            <pxi:message message=" * unknown test grammar: $1">
                <p:with-option name="param1" select="namespace-uri(/*)"/>
            </pxi:message>
            <p:delete match="/*/node()"/>
            <p:wrap-sequence wrapper="c:error"/>
            <p:insert match="/*" position="first-child">
                <p:input port="insertion">
                    <p:inline>
                        <replaceme/>
                    </p:inline>
                </p:input>
            </p:insert>
            <p:string-replace match="/*/replaceme" replace="Unknown XProc test grammar: "/>
            <p:wrap-sequence wrapper="c:errors"/>
            <p:add-attribute match="/*" attribute-name="test-grammar" attribute-value="Unknown"/>
        </p:otherwise>
    </p:choose>

    <p:for-each name="for-each">
        <p:output port="scenarios" sequence="true"/>
        <p:variable name="base" select="base-uri(/*)"/>

        <p:identity name="try.input"/>
        <p:try>
            <p:group>
                <p:output port="result" sequence="true"/>
                <p:choose>
                    <p:when test="/*[self::c:errors]">
                        <p:output port="result" sequence="true"/>
                        <pxi:message message=" * error document; skipping"/>
                        <p:identity/>
                    </p:when>
                    <p:otherwise>
                        <p:output port="result" sequence="true"/>

                        <p:identity name="main-document"/>

                        <p:group>
                            <p:variable name="script-uri" select="resolve-uri(/*/@script,base-uri(/*))"/>
                            <pxi:message message=" * extracting step declarations"/>

                            <p:for-each>
                                <p:iteration-source select="//x:call"/>
                                <p:add-attribute match="/*" attribute-name="step">
                                    <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@step,/*)),'}',tokenize(/*/@step,':')[last()])"/>
                                </p:add-attribute>
                                <p:delete match="/*/*"/>
                            </p:for-each>
                            <p:wrap-sequence wrapper="wrapper"/>
                            <p:delete match="x:call[concat('{',@step-namespace,'}',@step-name)=preceding::x:call/concat('{',@step-namespace,'}',@step-name)]"/>
                            <pxi:message message=" * tests reference $1 step$2">
                                <p:with-option name="param1" select="count(/*/*)"/>
                                <p:with-option name="param2" select="if (count(/*/*)=1) then '' else 's'"/>
                            </pxi:message>
                            <p:for-each>
                                <p:iteration-source select="/*/*"/>
                                <pxi:message message="   * step: $1">
                                    <p:with-option name="param1" select="/*/@step"/>
                                </pxi:message>
                                <p:identity/>
                            </p:for-each>
                            <p:identity name="calls"/>
                            
                            <p:try>
                                <p:group>
                                    <pxi:message message=" * trying to load: $1">
                                        <p:with-option name="param1" select="$script-uri"/>
                                    </pxi:message>
                                    <p:load>
                                        <p:with-option name="href" select="$script-uri"/>
                                    </p:load>
                                    <pxi:message message="   * success!"/>
                                </p:group>
                                <p:catch>
                                    <pxi:error code="XPS02" message=" * unable to load script: $1">
                                        <p:with-option name="param1" select="$script-uri"/>
                                    </pxi:error>
                                </p:catch>
                            </p:try>
                            <p:viewport match="//p:declare-step | //p:pipeline">
                                <p:add-attribute match="/*" attribute-name="x:type">
                                    <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@type,/*)),'}',tokenize(/*/@type,':')[last()])"/>
                                </p:add-attribute>
                            </p:viewport>
                            <p:identity name="script"/>

                            <p:for-each>
                                <p:iteration-source>
                                    <p:pipe port="result" step="calls"/>
                                </p:iteration-source>
                                <p:variable name="step" select="/*/@step"/>
                                <pxi:message message=" * trying to extract the step declaration for $1 from $2">
                                    <p:with-option name="param1" select="$step"/>
                                    <p:with-option name="param2" select="$script-uri"/>
                                </pxi:message>
                                <p:for-each>
                                    <p:iteration-source select="(//p:declare-step | //p:pipeline)[@x:type=$step]">
                                        <p:pipe port="result" step="script"/>
                                    </p:iteration-source>
                                    <p:identity/>
                                </p:for-each>
                                <p:identity name="step-declaration"/>
                                <p:count/>
                                <p:choose>
                                    <p:when test="number(.)=0">
                                        <!-- TODO: step not found; throw error? -->
                                        <pxi:error message=" * the step $1 was not found in $2" code="XPS01">
                                            <p:with-option name="param1" select="$step"/>
                                            <p:with-option name="param2" select="$script-uri"/>
                                        </pxi:error>
                                    </p:when>
                                    <p:otherwise>
                                        <p:identity>
                                            <p:input port="source">
                                                <p:pipe port="result" step="step-declaration"/>
                                            </p:input>
                                        </p:identity>
                                        <p:delete match="/*/*[not(self::p:input or self::p:output or self::p:option)]"/>
                                        <p:add-attribute match="/*/p:input[not(@sequence)] | /*/p:output[not(@sequence)]" attribute-name="sequence" attribute-value="false"/>
                                        <p:add-attribute match="/*/p:input[not(@kind)] | /*/p:output[not(@kind)]" attribute-name="kind" attribute-value="document"/>
                                    </p:otherwise>
                                </p:choose>
                            </p:for-each>
                            <p:for-each>
                                <p:insert match="/p:pipeline" position="first-child">
                                    <p:input port="insertion">
                                        <p:inline>
                                            <p:input port="source" primary="true" sequence="false" kind="document"/>
                                        </p:inline>
                                        <p:inline>
                                            <p:input port="parameters" primary="true" sequence="false" kind="parameter"/>
                                        </p:inline>
                                        <p:inline>
                                            <p:output port="result" primary="true" sequence="false" kind="document"/>
                                        </p:inline>
                                    </p:input>
                                </p:insert>
                                <p:delete match="/p:pipeline/p:input[@port=following-sibling::p:input/@port]"/>
                                <p:delete match="/p:pipeline/p:output[@port=following-sibling::p:output/@port]"/>
                                <p:rename match="/p:pipeline" new-name="p:declare-step"/>

                                <!-- infer whether each port is primary or secondary -->
                                <!-- a port is primary if it is the only port of its kind and the primary attribute is not false -->
                                <p:xslt>
                                    <p:input port="parameters">
                                        <p:empty/>
                                    </p:input>
                                    <p:input port="stylesheet">
                                        <p:document href="infer-primary-ports.xsl"/>
                                    </p:input>
                                </p:xslt>
                            </p:for-each>
                            <p:wrap-sequence wrapper="x:step-declaration"/>
                        </p:group>
                        <p:identity name="step-declarations"/>

                        <p:identity cx:depends-on="step-declarations">
                            <p:input port="source">
                                <p:pipe port="result" step="main-document"/>
                            </p:input>
                        </p:identity>
                        <pxi:message message=" * checking for imports">
                            <p:log port="result" href="file:/tmp/preprocess.import.in.xml"/>
                        </pxi:message>
                        <pxi:perform-imports>
                            <p:log port="result" href="file:/tmp/preprocess.import.out.xml"/>
                        </pxi:perform-imports>

                        <!--<p:for-each>
                            <p:output port="result" sequence="true"/>-->

                            <!-- create a new x:description document for each x:scenario element with inferred inputs, options and parameters -->
                            <pxi:message message=" * creating a new x:description document for each x:scenario element with inferred inputs, options and parameters"/>
                            <p:add-attribute match="/*" attribute-name="script">
                                <p:with-option name="attribute-value" select="resolve-uri(/*/@script,base-uri(/*))"/>
                            </p:add-attribute>
                            <p:viewport match="//x:call[@step]">
                                <p:add-attribute match="/*" attribute-name="x:step">
                                    <p:with-option name="attribute-value" select="concat('{',namespace-uri-from-QName(resolve-QName(/*/@step,/*)),'}',tokenize(/*/@step,':')[last()])"/>
                                </p:add-attribute>
                            </p:viewport>
                            <p:xslt>
                                <p:input port="parameters">
                                    <p:empty/>
                                </p:input>
                                <p:input port="stylesheet">
                                    <p:document href="infer-scenarios.xsl"/>
                                </p:input>
                            </p:xslt>
                            <p:for-each>
                                <p:iteration-source select="/*/*"/>
                                <p:variable name="step" select="(//x:call/@x:step)[1]"/>
                                <p:insert match="/*" position="first-child">
                                    <p:input port="insertion">
                                        <p:pipe port="result" step="step-declarations"/>
                                    </p:input>
                                </p:insert>
                                <p:delete>
                                    <p:with-option name="match" select="concat('/*/x:script-declaration/*[not(@x:type=&quot;',$step,'&quot;)]')"/>
                                </p:delete>
                            </p:for-each>
                        <!--</p:for-each>-->
                    </p:otherwise>
                </p:choose>
                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:group>
            <p:catch name="catch">
                <p:output port="result" sequence="true"/>
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="error" step="catch"/>
                    </p:input>
                </p:identity>
                <pxi:message message=" * an error occured while flattening scenario(s)"/>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$base"/>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="error-location" attribute-value="preprocess.xpl - flatten scenario(s) and get step declaration"/>

                <p:identity name="errors-without-was"/>
                <p:wrap-sequence wrapper="x:was">
                    <p:input port="source">
                        <p:pipe port="result" step="try.input"/>
                    </p:input>
                </p:wrap-sequence>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                </p:add-attribute>
                <p:wrap-sequence wrapper="c:error"/>
                <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                <p:identity name="was"/>
                <p:insert match="/*" position="last-child">
                    <p:input port="source">
                        <p:pipe port="result" step="errors-without-was"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="was"/>
                    </p:input>
                </p:insert>

                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:catch>
        </p:try>
        <p:for-each>
            <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
            <p:iteration-source select="/calabash-issue-102/*"/>
            <p:identity/>
        </p:for-each>

        <p:for-each>
            <p:add-attribute match="/*" attribute-name="test-base-uri">
                <p:with-option name="attribute-value" select="$test-base-uri">
                    <p:empty/>
                </p:with-option>
            </p:add-attribute>
        </p:for-each>
    </p:for-each>
    
    <!-- validate output grammar -->
    <p:for-each>
        <p:identity name="try.input"/>
        <pxi:message message=" * validating output grammar"/>
        <p:try>
            <p:group>
                <p:validate-with-relax-ng>
                    <p:input port="schema">
                        <p:document href="../../schema/xprocspec.preprocess.rng"/>
                    </p:input>
                </p:validate-with-relax-ng>
                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:group>
            <p:catch name="catch">
                <p:identity>
                    <p:input port="source">
                        <p:pipe port="error" step="catch"/>
                    </p:input>
                </p:identity>
                <pxi:message message=" * an error occured while validating output grammar"/>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="$test-base-uri"/>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="test-base-uri">
                    <p:with-option name="attribute-value" select="$test-base-uri"/>
                </p:add-attribute>
                <p:add-attribute match="/*" attribute-name="error-location" attribute-value="preprocess.xpl - validate output grammar"/>

                <p:identity name="errors-without-was"/>
                <p:wrap-sequence wrapper="x:was">
                    <p:input port="source">
                        <p:pipe port="result" step="try.input"/>
                    </p:input>
                </p:wrap-sequence>
                <p:add-attribute match="/*" attribute-name="xml:base">
                    <p:with-option name="attribute-value" select="base-uri(/*/*)"/>
                </p:add-attribute>
                <p:wrap-sequence wrapper="c:error"/>
                <p:add-attribute match="/*" attribute-name="type" attribute-value="was"/>
                <p:identity name="was"/>
                <p:insert match="/*" position="last-child">
                    <p:input port="source">
                        <p:pipe port="result" step="errors-without-was"/>
                    </p:input>
                    <p:input port="insertion">
                        <p:pipe port="result" step="was"/>
                    </p:input>
                </p:insert>

                <p:wrap-sequence wrapper="calabash-issue-102"/>
            </p:catch>
        </p:try>
        <p:for-each>
            <!-- temporary fix for https://github.com/ndw/xmlcalabash1/issues/102 -->
            <p:iteration-source select="/calabash-issue-102/*"/>
            <p:identity/>
        </p:for-each>
    </p:for-each>
    <p:identity name="result"/>

</p:declare-step>
