import type { TenantRole } from "@prisma/client";
export type Permission = "business:read"|"business:write"|"campaign:write"|"feedback:read"|"analytics:read"|"team:manage"|"billing:manage"|"settings:manage";
const all: Permission[] = ["business:read","business:write","campaign:write","feedback:read","analytics:read","team:manage","billing:manage","settings:manage"];
const map: Record<TenantRole, Permission[]> = {
  OWNER: all, ADMIN: all, MANAGER: all.filter(x => x !== "billing:manage"), STAFF: ["business:read","campaign:write","feedback:read"], VIEWER: ["business:read","feedback:read","analytics:read"],
  AGENCY_OWNER: all, AGENCY_ADMIN: all, AGENCY_STAFF: ["business:read","business:write","campaign:write","feedback:read","analytics:read"]
};
export function can(role: TenantRole, permission: Permission) { return map[role].includes(permission); }
