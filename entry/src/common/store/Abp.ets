import preferencesManager from '../utils/PreferencesManager'


export interface CurrentUser {
  isAuthenticated: boolean;
  id: string | null;
  tenantId: string | null;
  impersonatorUserId: string | null;
  impersonatorTenantId: string | null;
  impersonatorUserName: string | null;
  impersonatorTenantName: string | null;
  userName: string | null;
  name: string | null;
  surName: string | null;
  email: string | null;
  emailVerified: boolean;
  phoneNumber: string | null;
  phoneNumberVerified: boolean;
  roles: string[];
  sessionId: string | null;
}

export interface Auth {
  grantedPolicies: Record<string, boolean>
}


class AbpState {
  auth: Auth;
  currentUser: CurrentUser;
  features: Map<string, Object>;
  globalFeatures: Map<string, Object>;
  settings: Map<string, Object>;
  localization: Map<string, Object>;

  constructor() {
    const authStr = preferencesManager.get('AbpState', 'abpAuth');
    if (authStr) {
      this.auth = JSON.parse(authStr) as Auth;
    }
    else
    {
      this.auth = {} as Auth
    }
    const currentUserStr = preferencesManager.get('AbpState', 'abpCurrentUser');
    if (currentUserStr) {
      this.currentUser = JSON.parse(currentUserStr) as CurrentUser;
    } else {
      this.currentUser =  {
        isAuthenticated:false
      } as CurrentUser;
    }
    this.features = preferencesManager.getMap('AbpState', 'abpFeatures');
    this.globalFeatures = preferencesManager.getMap('AbpState', 'abpGlobalFeatures');
    this.settings = preferencesManager.getMap('AbpState', 'abpSettings');
    this.localization = preferencesManager.getMap('AbpState', 'abpLocalization');
  }

  getAuth(): Auth {
    return this.auth;
  }

  setAuth(value: Auth): void {
    this.auth = value;
    preferencesManager.set('AbpState', 'abpAuth', value);
  }

  hasPermission(permission: string): boolean {
    const auth = this.getAuth();
    return auth.grantedPolicies?.[permission] === true || false;
  }

  CurrentUser(): CurrentUser {
    return this.currentUser;
  }

  setCurrentUser(value:CurrentUser): void {
    this.currentUser = value;
    preferencesManager.set('AbpState', 'abpCurrentUser', value);
  }

  getFeatures(): Map<string, Object> {
    return this.features;
  }

  setFeatures(value: Map<string, Object>): void {
    this.features = value;
    preferencesManager.setMap('AbpState', 'abpFeatures', value);
  }

  getGlobalFeatures(): Map<string, Object> {
    return this.globalFeatures;
  }

  setGlobalFeatures(value: Map<string, Object>): void {
    this.globalFeatures = value;
    preferencesManager.setMap('AbpState', 'abpGlobalFeatures', value);
  }

  getSettings(): Map<string, Object> {
    return this.settings;
  }

  setSettings(value: Map<string, Object>): void {
    this.settings = value;
    preferencesManager.setMap('AbpState', 'abpSettings', value);
  }

  getLocalization(): Map<string, Object> {
    return this.localization;
  }

  setLocalization(value: Map<string, Object>): void {
    this.localization = value;
    preferencesManager.setMap('AbpState', 'abpLocalization', value);
  }
}

const abp = new AbpState();
export default abp;