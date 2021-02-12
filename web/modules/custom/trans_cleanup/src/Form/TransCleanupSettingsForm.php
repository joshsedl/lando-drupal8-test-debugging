<?php

/**
 * @file
 * Contains \Drupal\trans_cleanup\Form\DrowlHeaderSlidesSettingsForm.
 */

namespace Drupal\trans_cleanup\Form;

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\system\Entity\Menu;

/**
 * Administration settings form.
 */
class TransCleanupForm extends ConfigFormBase
{

  /**
   * {@inheritdoc}
   */
  public function getFormID()
  {
    return 'trans_cleanup_form';
  }

  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames()
  {
    return [];
  }

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state)
  {
    $form['select123'] = [
      '#type' => 'select',
      '#title' => $this->t('Menus containing header images'),
      '#description' => $this->t('Select the menus to watch for header images.'),
      '#default_value' => !empty($selectedMenus) ? $selectedMenus : ['main'],
      '#options' => ['abc'],
      '#multiple' => true,
      '#required' => true
    ];

    return parent::buildForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function validateForm(array &$form, FormStateInterface $form_state)
  {
    parent::validateForm($form, $form_state);
  }

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state)
  {
    parent::submitForm($form, $form_state);
  }

  public function TODOCONFIRMED123(){
    // Example:
    $queryHelper = Drupal::service('trans_cleanup.query_helper');
    // Run deleteEqualTranslation()
    $queryHelper->deleteEqualTranslation();
  }
}
