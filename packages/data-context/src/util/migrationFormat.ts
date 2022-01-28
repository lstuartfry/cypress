import dedent from 'dedent'

export interface FilePart {
  text: string
  highlight: boolean
}

function getLegacyHighlightRegexp (defaultFolder: 'integration' | 'component') {
  return `cypress\/(?<main>${defaultFolder})\/.*?(?<ext>[._-]?[s|S]pec.|[.])(?=[j|t]s[x]?)`
}

function getNewHighlightRegexp (defaultFolder: 'e2e' | 'component') {
  return `cypress\/(?<main>${defaultFolder})\/.*?(?<ext>.cy.)`
}

export const supportFileRegexps = {
  e2e: {
    beforeRegexp: 'cypress/\support\/(?<main>index)\.(?=[j|t]s[x]?)',
    afterRegexp: 'cypress/\support\/(?<main>e2e)\.(?=[j|t]s[x]?)',
  },
  component: {
    beforeRegexp: 'cypress/\support\/(?<file>index)\.(?=[j|t]s[x]?)',
    afterRegexp: 'cypress/\support\/(?<file>e2e)\.(?=[j|t]s[x]?)',
  },
} as const

export const regexps = {
  e2e: {
    usingDefaultIntegrationFolder: {
      beforeRegexp: getLegacyHighlightRegexp('integration'),
      afterRegexp: getNewHighlightRegexp('e2e'),
    },
    usingCustomIntegrationFolder: {
      beforeRegexp: (folder: string) => `${folder}\/.*?(?<ext>[._-]?[s|S]pec.|[.])(?=[j|t]s[x]?)`,
      afterRegexp: (folder: string) => `${folder}\/.*?(?<ext>.cy.)`,
    },
  },
} as const

export function formatMigrationFile (file: string, regexp: RegExp): FilePart[] {
  const match = regexp.exec(file)

  if (!match?.groups) {
    throw new Error(dedent`
      Expected groups main and ext in ${file} using ${regexp} when matching ${file}
      Perhaps this isn't a spec file, or it is an unexpected format?`)
  }

  // sometimes `.` gets in here as the <ext> group
  // filter it out
  const higlights = Object.values(match.groups).filter((x) => x.length > 1)
  const delimiters = higlights.join('|')
  const re = new RegExp(`(${delimiters})`)
  const split = file.split(re)

  return split.map<FilePart>((text) => {
    return {
      text,
      highlight: higlights.includes(text),
    }
  })
}