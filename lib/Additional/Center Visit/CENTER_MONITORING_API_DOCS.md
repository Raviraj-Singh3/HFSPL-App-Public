# Center Monitoring API Documentation

## Overview
This document outlines the API endpoints required to implement the Center Monitoring functionality in the mobile app, based on the existing CenterMonitor.aspx and CenterMonitor.aspx.cs functionality.

## Base URL
```
https://your-api-domain.com/api/CenterMonitoring
```

## API Endpoints

### 1. Get Meeting Types
**Endpoint:** `GET /GetMeetingTypes`

**Description:** Retrieves all available meeting types for center monitoring.

**Response:**
```json
[
  {
    "ID": 1,
    "TYPEOFMEET": "Regular Meeting"
  },
  {
    "ID": 3,
    "TYPEOFMEET": "Special Meeting"
  }
]
```

**Notes:** 
- Should exclude meeting type with ID=2 (as per original C# code)
- For FE users, should default to ID=2 and disable selection

---

### 2. Get Centers by FE and Filter
**Endpoint:** `GET /GetCentersByFeAndFilter?feId={feId}&filterType={filterType}`

**Parameters:**
- `feId` (int): Field Executive ID
- `filterType` (int): Filter type (0=All, 1=Pending, 2=More than 3 months)

**Description:** Retrieves centers based on FE ID and filter criteria.

**Filter Logic:**
- `0 (All)`: All centers assigned to the FE with active members
- `1 (Pending)`: Centers that have never been monitored
- `2 (More than 3 months)`: Centers not monitored in the last 90 days

**Response:**
```json
[
  {
    "id": 101,
    "name": "Center ABC"
  },
  {
    "id": 102,
    "name": "Center XYZ"
  }
]
```

**SQL Logic Reference (from C# code):**
```sql
-- For filterType = 0 (All)
SELECT DISTINCT c.CENTERID as id, c.CENTERNAME as name
FROM TBL_CENTER_MASTER c
JOIN groupshg g ON c.CENTERID = g.centerId
JOIN client cl ON g.id = cl.groupId
JOIN V1Master v1 ON cl.id = v1.client_id
JOIN member_info mi ON v1.id = mi.v_id
WHERE mi.status = 'active' AND c.FENAME = @feId
ORDER BY name

-- For filterType = 1 (Pending)
-- Same as above but exclude centers that exist in TBL_CENTERMONITOR

-- For filterType = 2 (More than 3 months)
-- Same as above but exclude centers monitored in last 90 days
```

---

### 3. Get Groups by Center
**Endpoint:** `GET /GetGroupsByCenter?centerId={centerId}`

**Parameters:**
- `centerId` (int): Center ID

**Description:** Retrieves all active groups for a specific center.

**Response:**
```json
[
  {
    "id": 201,
    "name": "Group Alpha",
    "selected": false
  },
  {
    "id": 202,
    "name": "Group Beta",
    "selected": false
  }
]
```

---

### 4. Get Members by Groups
**Endpoint:** `POST /GetMembersByGroups`

**Request Body:**
```json
{
  "groupIds": [201, 202, 203]
}
```

**Description:** Retrieves all active members for selected groups.

**Response:**
```json
[
  {
    "Id": 1001,
    "Name": "John Doe",
    "RelativeName": "Father: Robert Doe",
    "selected": true,
    "observation": ""
  },
  {
    "Id": 1002,
    "Name": "Jane Smith",
    "RelativeName": "Husband: Mike Smith",
    "selected": true,
    "observation": ""
  }
]
```

**SQL Logic Reference:**
```sql
SELECT cl.id as Id, cl.Name, cl.relativeName as RelativeName
FROM client cl
JOIN V1Master v1 ON cl.id = v1.client_id
JOIN member_info mi ON v1.id = mi.v_id
WHERE mi.status = 'active' AND cl.groupId IN (@groupIds)
```

---

### 5. Submit Center Monitoring
**Endpoint:** `POST /SubmitMonitoring`

**Content-Type:** `multipart/form-data`

**Request Parameters:**
- `centerId` (int): Center ID
- `staffId` (int): Staff/Visitor ID (usually the logged-in user ID)
- `meetingTypeId` (int): Meeting type ID
- `groupIds` (string): JSON array of group IDs
- `groupObservation` (string): Group observation (required)
- `centerObservation` (string): Center observation (optional)
- `members[i].clientId` (int): Client ID for member i
- `members[i].observation` (string): Observation for member i
- `members[i].photo` (file): Photo file for member i

**Description:** Submits center monitoring data with member photos and observations.

**Response:**
```json
{
  "success": true,
  "message": "Center monitoring submitted successfully",
  "monitoringId": 12345
}
```

**Database Operations:**
1. **TBL_CENTERMONITOR Table:**
   - Check if center already monitored today
   - Insert/Update center monitoring record
   
2. **TBL_CENTERMONITOR_GROUP Table:**
   - Insert group monitoring records for each selected group
   
3. **TBL_CENTERMONITOR_MEMBER Table:**
   - Insert member monitoring records with observations and photo paths
   
4. **File Upload:**
   - Save photos to `/uploads1/` directory
   - Filename format: `{clientId}_{date}.{extension}`

**Error Responses:**
```json
{
  "success": false,
  "message": "Error message describing the issue"
}
```

---

## Database Schema

### Required Tables

#### TBL_CENTERMONITOR
```sql
TID (int, Primary Key, Auto Increment)
cby (int) -- Created by user ID
cdate (datetime) -- Creation date
Centerid (int) -- Center ID
Remark (nvarchar) -- Center observation
st (bit) -- Status (always true)
StaffID (int) -- Staff/Visitor ID
Typeofmeeting (int) -- Meeting type ID
```

#### TBL_CENTERMONITOR_GROUP
```sql
Id (int, Primary Key, Auto Increment)
GroupId (int) -- Group ID
TID (int) -- Reference to TBL_CENTERMONITOR.TID
Observation (nvarchar) -- Group observation
```

#### TBL_CENTERMONITOR_MEMBER
```sql
Id (int, Primary Key, Auto Increment)
MonitorGroupId (int) -- Reference to TBL_CENTERMONITOR_GROUP.Id
ClientId (int) -- Client/Member ID
Observation (nvarchar) -- Member observation
Filepath (nvarchar) -- Photo file path
CDate (datetime) -- Creation date
```

---

## Authentication & Authorization

All endpoints require:
- **Authorization Header:** Basic authentication with format `Basic {base64(username---token:password)}`
- **User Permissions:** User must have appropriate role permissions (FE, OtherFieldMember, etc.)

---

## Error Handling

Common error scenarios:
1. **Invalid FE ID:** Return empty centers list
2. **No groups found:** Return empty groups list
3. **File upload failure:** Return error with specific message
4. **Database constraints:** Handle duplicate entries gracefully
5. **Missing required fields:** Validate and return appropriate error messages

---

## Implementation Notes

1. **File Upload Path:** Ensure `/uploads1/` directory has proper write permissions
2. **Image Processing:** Consider image compression and validation
3. **Date Handling:** Use server date/time for consistency
4. **Transaction Management:** Wrap database operations in transactions
5. **Logging:** Log all monitoring submissions for audit purposes
6. **Performance:** Consider caching for dropdown data that doesn't change frequently

---

## Testing Checklist

- [ ] Branch and staff dropdowns populate correctly
- [ ] Meeting types load (excluding ID=2 for non-FE users)
- [ ] Center filtering works for all three filter types
- [ ] Group selection enables/disables member list
- [ ] Member list displays correctly with all required fields
- [ ] Photo capture and preview works on mobile devices
- [ ] Form validation prevents submission with missing data
- [ ] File upload works and files are saved correctly
- [ ] Database records are created in all three tables
- [ ] Error handling works for various failure scenarios
- [ ] Success message displays after successful submission
- [ ] Form resets after successful submission
