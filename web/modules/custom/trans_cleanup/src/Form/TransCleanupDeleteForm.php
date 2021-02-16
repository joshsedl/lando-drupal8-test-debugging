<?php

namespace Drupal\trans_cleanup\Form;

use Drupal\Core\Entity\EntityDeleteForm;
use Drupal\Core\Url;

/**
 * Defines a confirmation form for deleting a language entity.
 *
 * @internal
 */
class TransCleanupDeleteForm extends EntityDeleteForm
{
  /**
   * {@inheritdoc}
   */
  public function getDescription()
  {
    return $this->t('Deleting Database entries could lead to problems. This action cannot be undone.');
  }

  /**
   * {@inheritdoc}
   */
  public function getCancelUrl()
  {
    return new Url('trans_cleanup.form');
  }

  /**
   * {@inheritdoc}
   */
  public function getFormId()
  {
    return 'trans_cleanup_delete_form';
  }

  /**
   * {@inheritdoc}
   */
  protected function getDeletionMessage()
  {
    return $this->t('The %language (%langcode) language has been removed.', ['%language' => $this->entity->label(), '%langcode' => $this->entity->id()]);
  }

  /**
   * {@inheritdoc}
   */
  public function logDeletionMessage()
  {
    $this->logger('language')->notice('The %language (%langcode) language has been removed.', ['%language' => $this->entity->label(), '%langcode' => $this->entity->id()]);
  }
}
