<?php

namespace Drupal\trans_cleanup;

/**
 *
 */
class QueryHelper {

  /**
   * Lists all Translations, where the target and source translation are the same.
   */
  public function listEqualTranslations()
  {
    $database = \Drupal::database();
    $query = $database->select('locales_source', 'ls');
    $query->innerJoin('locales_target', 'lt', 'ls.lid=lt.lid');
    $query
      ->fields('ls', ['lid', 'source'])
      ->fields('lt', ['translation'])
      ->condition('ls.lid', 'lt.lid')
      ->condition('lt.customized', 1)
      ->where('CONVERT(ls.source USING utf8) = CONVERT(lt.translation USING utf8)');

    $result = $query->execute()->fetchAll();
    return $result;
  }


  // Deletes all translations, where the target and source translation are the same
  public function deleteEqualTranslation()
  {
    $database = \Drupal::database();
    $num_deleted = $database->delete('locales_target')
      ->where('lid IN (SELECT lid FROM (SELECT ls.lid FROM locales_source ls
              INNER JOIN locales_target lt
              WHERE ls.lid=lt.lid
              AND CONVERT(ls.source USING utf8) = CONVERT(lt.translation USING utf8)
              AND lt.customized=1) temp)')
      // Stores the  number of records that were deleted as a result of the query.
      ->execute();


    return $num_deleted;
  }

  // Lists all translations, which have no target translation
  public function listOrphanTranslations()
  {
    $database = \Drupal::database();
    $query = $database->select('local_source','ls');
    $query->leftJoin('locales_target','lt', 'ls.lid=lt.lid');
    $query->fields('ls', ['lid'])
      ->condition('lt.lid', NULL);

    $result = $query->execute()->fetchAll();
    return $result;
  }

  // Deletes all translations, which have no target translation
  public function deleteOrphanTranslations()
  {
    $database = \Drupal::database();
    // Doesn't make sense in delete() query as too complex:
    $num_deleted = $database->query('DELETE ls FROM `locales_source` ls LEFT JOIN locales_target lt ON ls.lid=lt.lid WHERE lt.lid IS NULL;')->execute();
    return $num_deleted;
  }

  // List all translation_status entries
  public function listCurrentTranslationStatus()
  {
    $database = \Drupal::database();
    $query = $database->select('key_value', 'kv');
    $query->condition('collection', 'locale.translation_status')
      ->fields('kv', ['collection', 'name', 'value']);

    $result = $query->execute()->fetchAll();
    return $result;
  }

  // Delete all translation_status entries
  public function deleteCurrenttranslationStatus()
  {
    $database = \Drupal::database();
    $num_deleted = $database->delete('key_value')
      ->condition('collection', 'locale.translation_status')
      ->execute();

    return $num_deleted;
  }

  // Resets locale_file timestamp,  last checked date, local last checked date
  // ANMERKUNG: evtl. in deleteCurrenttranslationStatus() packen
  public function resetTranslationStatus()
  {
    $database = \Drupal::database();
    $database->update('locale_file')
      ->fields([
        'timestamp' => '0',
        'last_checked' => '0'
      ]);
    \Drupal::state()->set('locale.translation_last_checked', 0);
  }

}
