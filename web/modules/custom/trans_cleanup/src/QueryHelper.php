<?php

namespace Drupal\trans_cleanup;

use Exception;

/**
 *  A class with several functions for Translation Cleanups in the database
 */
class QueryHelper
{

  /**
   * Lists all Translations, where the target and source translation are the same.
   *
   * @return false Returns the equal translations list.
   */
  public function getEqualTranslations()
  {
    try {
      $database = \Drupal::database();
      $query = $database->select('locales_source', 'ls');
      $query->innerJoin('locales_target', 'lt', 'ls.lid=lt.lid');
      $query
        ->fields('ls', ['lid', 'source'])
        ->fields('lt', ['translation'])
        ->condition('lt.customized', 1)
        ->where('CONVERT(ls.source USING utf8) = CONVERT(lt.translation USING utf8)');

      $result = $query->execute()->fetchAll();
      return $result;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * Deletes all translations, where the target and source translation are the same
   *
   * @return false Returns the equal translations list.
   */
  public function deleteEqualTranslations()
  {
    try {
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
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * Lists all translations, which have no target translation
   *
   * @return false Returns the equal translations list.
   */
  public function getOrphanTranslations()
  {
    try {
      $database = \Drupal::database();
      $query = $database->select('locales_source', 'ls');
      $query->leftJoin('locales_target', 'lt', 'ls.lid=lt.lid');
      $query->fields('ls', ['lid'])
        ->isNull('lt.lid'); //condition doesn't work for NULL checking

      $result = $query->execute()->fetchAll();
      return $result;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * Deletes all translations, which have no target translation
   *
   * @return false Returns the equal translations list.
   */
  public function deleteOrphanTranslations()
  {
    try {
      $database = \Drupal::database();
      // Doesn't make sense in delete() query as too complex:
      $result = $database->query('DELETE ls FROM `locales_source` ls LEFT JOIN locales_target lt ON ls.lid=lt.lid WHERE lt.lid IS NULL;')->execute();
      $num_deleted = $result->rowCount();
      return $num_deleted;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * List all translation_status entries
   *
   * @return false Returns the equal translations list.
   */
  public function getStatusTranslations()
  {
    try {
      $database = \Drupal::database();
      $query = $database->select('key_value', 'kv');
      $query->condition('collection', 'locale.translation_status')
        ->fields('kv', ['collection', 'name', 'value']);

      $result = $query->execute()->fetchAll();
      return $result;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * Delete all translation_status entries
   *
   * @return false Returns the equal translations list.
   */
  public function deleteStatusTranslations()
  {
    try {
      $database = \Drupal::database();
      $num_deleted = $database->delete('key_value')
        ->condition('collection', 'locale.translation_status')
        ->execute();

      return $num_deleted;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * Resets locale_file timestamp,  last checked date, local last checked date
   *
   * @return false Returns the equal translations list.
   */
  public function resetStatusTranslations()
  {
    try {
      $database = \Drupal::database();
      $database->update('locale_file')
        ->fields([
          'timestamp' => '0',
          'last_checked' => '0'
        ]);
      \Drupal::state()->set('locale.translation_last_checked', 0);
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }

  /**
   * deletes and resets Translationstatus
   *
   * @return false Returns the equal translations list.
   */
  public function deleteResetStatusTranslations()
  {
    try {
      $num_deleted = $this->deleteStatusTranslations();
      $this->resetStatusTranslations();
      return $num_deleted;
    } catch (Exception $e) {
      \Drupal::logger('trans_cleanup')->error($e->getMessage());
      return false;
    }
  }
}
