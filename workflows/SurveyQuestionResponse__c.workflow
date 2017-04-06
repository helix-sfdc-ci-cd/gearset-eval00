<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><fieldUpdates>
        <fullName>Populate_Comments_Field</fullName>
        <description>Copy Response into Comments Field</description>
        <field>Comments__c</field>
        <formula>Response__c</formula>
        <name>Populate Comments Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Populate_Rating_Field</fullName>
        <field>Rating__c</field>
        <formula>Response__c</formula>
        <name>Populate Rating Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Populate Comments Field</fullName>
        <actions>
            <name>Populate_Comments_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Survey_Question__c.Type__c</field>
            <operation>equals</operation>
            <value>Free Text</value>
        </criteriaItems>
        <description>Copies free text response to "Comments" field. This allows free text answers to be in the "details" section of reports but omitted from charts.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Populate Rating Field</fullName>
        <actions>
            <name>Populate_Rating_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Survey_Question__c.Type__c</field>
            <operation>equals</operation>
            <value>Single Select--Vertical</value>
        </criteriaItems>
        <description>Copies score to "Rating" field. Having separate fields for rating/comments allows free text answers to be in the "details" section of reports but only show the rating/score in the chart.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules></Workflow>