import { Tool } from "@modelcontextprotocol/sdk/types.js";

export const SALESFORCE_TOOLS: Tool[] = [
  {
    name: "salesforce_list_objects",
    description: "List all available Salesforce objects (sObjects) in the org. Use this to discover what data is available before querying.",
    inputSchema: {
      type: "object",
      properties: {
        include_custom: {
          type: "boolean",
          description: "Include custom objects (ending in __c). Default: true",
        },
        include_standard: {
          type: "boolean",
          description: "Include standard objects (Account, Contact, etc.). Default: true",
        },
      },
    },
  },
  {
    name: "salesforce_describe",
    description: "Get the schema for a Salesforce object: its fields, types, relationships, and picklist values. Always call this before creating or updating records to know the required fields.",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object, e.g. Account, Contact, Opportunity, MyObject__c",
        },
      },
      required: ["object_name"],
    },
  },
  {
    name: "salesforce_query",
    description: "Execute a SOQL (Salesforce Object Query Language) query. Returns records matching the query. Use salesforce_describe to know available fields. Supports pagination via next_page_token.",
    inputSchema: {
      type: "object",
      properties: {
        soql: {
          type: "string",
          description: "SOQL query string, e.g. SELECT Id, Name, Email FROM Contact WHERE AccountId = '001...' LIMIT 20",
        },
        next_page_token: {
          type: "string",
          description: "Token from a previous query response to fetch the next page of results",
        },
      },
      required: ["soql"],
    },
  },
  {
    name: "salesforce_search",
    description: "Execute a SOSL (Salesforce Object Search Language) full-text search across multiple objects simultaneously.",
    inputSchema: {
      type: "object",
      properties: {
        sosl: {
          type: "string",
          description: "SOSL query, e.g. FIND {John Smith} IN ALL FIELDS RETURNING Contact(Id, Name, Email), Account(Id, Name)",
        },
      },
      required: ["sosl"],
    },
  },
  {
    name: "salesforce_get",
    description: "Retrieve a single Salesforce record by its ID. Optionally specify which fields to return.",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object, e.g. Account",
        },
        record_id: {
          type: "string",
          description: "Salesforce record ID (15 or 18 character)",
        },
        fields: {
          type: "array",
          items: { type: "string" },
          description: "Specific fields to return. If omitted, returns all readable fields.",
        },
      },
      required: ["object_name", "record_id"],
    },
  },
  {
    name: "salesforce_create",
    description: "Create a new Salesforce record. Use salesforce_describe first to understand required fields and data types.",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object, e.g. Account, Contact, Lead",
        },
        fields: {
          type: "object",
          description: "Field name/value pairs for the new record, e.g. { Name: 'Acme Corp', Industry: 'Technology' }",
        },
      },
      required: ["object_name", "fields"],
    },
  },
  {
    name: "salesforce_update",
    description: "Update an existing Salesforce record by ID.",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object",
        },
        record_id: {
          type: "string",
          description: "Salesforce record ID (15 or 18 character)",
        },
        fields: {
          type: "object",
          description: "Field name/value pairs to update. Only specified fields are changed.",
        },
      },
      required: ["object_name", "record_id", "fields"],
    },
  },
  {
    name: "salesforce_delete",
    description: "Delete a Salesforce record by ID. This action cannot be undone (record moves to Recycle Bin).",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object",
        },
        record_id: {
          type: "string",
          description: "Salesforce record ID to delete",
        },
      },
      required: ["object_name", "record_id"],
    },
  },
  {
    name: "salesforce_bulk_create",
    description: "Create multiple records at once using Salesforce Bulk API 2.0. More efficient than individual creates for 200+ records.",
    inputSchema: {
      type: "object",
      properties: {
        object_name: {
          type: "string",
          description: "API name of the Salesforce object",
        },
        records: {
          type: "array",
          items: { type: "object" },
          description: "Array of record field objects to create",
        },
      },
      required: ["object_name", "records"],
    },
  },
  {
    name: "salesforce_get_limits",
    description: "Get the current API usage and limits for the connected Salesforce org. Use this to check remaining API calls before large operations.",
    inputSchema: {
      type: "object",
      properties: {},
    },
  },
];
