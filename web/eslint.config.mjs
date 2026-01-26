// @ts-check
import withNuxt from './.nuxt/eslint.config.mjs'
import oxlint from 'eslint-plugin-oxlint'

/**
 * Wrap the full config with `withNuxt()`
 */
export default withNuxt(...oxlint.configs['flat/recommended'])
