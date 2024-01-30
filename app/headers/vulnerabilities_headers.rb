# frozen_string_literal: true

class VulnerabilitiesHeaders < HeadersHandler
  TABS = {
    all: {
      subtitle: 'vulnerabilities.section_subtitle',
      label: 'scopes.all',
      href: 'vulnerabilities_path',
      badge: '_data.count',
      icon: Icons::MAT[:vulnerabilities]
    },
    burp: {
      subtitle: 'vulnerabilities.scopes.burp.subtitle',
      label: 'vulnerabilities.scopes.burp.name',
      href: 'burp_vulnerabilities_path',
      badge: '_data.burp_kb_type.count',
      logo: Icons::LOGOS[:burp]
    },
    qualys: {
      subtitle: 'vulnerabilities.scopes.qualys.subtitle',
      label: 'vulnerabilities.scopes.qualys.name',
      href: 'qualys_vulnerabilities_path',
      badge: '_data.qualys_kb_type.count',
      logo: Icons::LOGOS[:qualys]
    },
    cve: {
      subtitle: 'vulnerabilities.scopes.cve.subtitle',
      label: 'vulnerabilities.scopes.cve.name',
      href: 'cve_vulnerabilities_path',
      badge: '_data.cve_kb_type.count',
      logo: Icons::LOGOS[:cve]
    },
    nessus: {
      subtitle: 'vulnerabilities.scopes.nessus.subtitle',
      label: 'vulnerabilities.scopes.nessus.name',
      href: 'nessus_vulnerabilities_path',
      badge: '_data.nessus_kb_type.count',
      logo: Icons::LOGOS[:nessus]
    },
    zaproxy: {
      subtitle: 'vulnerabilities.scopes.zaproxy.subtitle',
      label: 'vulnerabilities.scopes.zaproxy.name',
      href: 'zaproxy_vulnerabilities_path',
      badge: '_data.zaproxy_kb_type.count',
      logo: Icons::LOGOS[:zaproxy]
    },
    cyberwatch: {
      subtitle: 'vulnerabilities.scopes.cyberwatch.subtitle',
      label: 'vulnerabilities.scopes.cyberwatch.name',
      href: 'cyberwatch_vulnerabilities_path',
      badge: '_data.cyberwatch_kb_type.count',
      logo: Icons::LOGOS[:cyberwatch]
    },
    imports: {
      label: 'models.imports',
      href: 'vulnerabilities_imports_path',
      icon: Icons::MAT[:download]
    }
  }.freeze

  ACTIONS = {
    import: {
      label: 'vulnerabilities.actions.import',
      href: 'new_vulnerabilities_import_path()',
      method: :get,
      icon: Icons::MAT[:download]
    }
  }.freeze

  def initialize
    super(TABS, ACTIONS)
  end
end
