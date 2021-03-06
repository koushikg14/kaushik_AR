<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>alert123</fullName>
        <ccEmails>kcs4u4@gmail.com</ccEmails>
        <description>alert123</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/asdasd</template>
    </alerts>
    <rules>
        <fullName>A</fullName>
        <actions>
            <name>alert123</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>A__c.Hello__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>