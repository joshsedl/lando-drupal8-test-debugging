<?php

/**
 * @file
 * Contains \Drupal\trans_cleanup\Form\DrowlHeaderSlidesSettingsForm.
 */

namespace Drupal\trans_cleanup\Form;

use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\ConfirmFormBase;
use Drupal\Core\Form\FormStateInterface;
use Drupal\system\Entity\Menu;
use Drupal\Core\Messenger\MessengerTrait;
use Drupal\Core\Url;
use Drupal\Core\Ajax\AjaxResponse;

/**
 * Administration settings form.
 */
class TransCleanupForm extends FormBase
{
  use MessengerTrait;

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
    $form['equalTranslations'] = array(
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this
        ->t('Equal translations'),
        '#description' => $this->t('Lists/Deletes translations, where the source language equals the target translation')
    );

    $form['equalTranslations']['equalTranslationsListWrapper'] = [
      '#type' => 'container',
      '#attributes' => ['id' => 'equalTranslationsListWrapper'],
    ];

    $form['equalTranslations']['equalSubmitList'] = [
      '#type' => 'submit',
      '#value' => $this->t('Get Equal translations'),
      '#description' => $this->t('List translations, where the source language
                        equals the target translation'),
      '#ajax' => [
        'wrapper' => 'equalTranslationsListWrapper',
        'callback' => '::getEqualTranslationsCallback',
      ],
    ];

    $form['equalTranslations']['equalSubmitDel'] = [
      '#type' => 'submit',
      '#value' => $this->t('Delete Equal translations'),
      '#description' => $this->t('Delete translations, where the source language
                        equals the target translation'),
      '#submit' => ['\Drupal\trans_cleanup\Form\TransCleanupDeleteForm::buildForm']
    ];

    $form['orphanTranslations'] = array(
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this
        ->t('Orphan translations'),
      '#description' => $this->t('Lists/Deletes translations, which have no target translation')
    );

    $form['orphanTranslations']['orphanTranslationsListWrapper'] = [
      '#type' => 'container',
      '#attributes' => ['id' => 'orphanTranslationsListWrapper'],
    ];

    $form['orphanTranslations']['orphanSubmitList'] = [
      '#type' => 'submit',
      '#value' => $this->t('Get Orphan translations'),
      '#description' => $this->t('List translations, which have no target
                        translation'),
      '#ajax' => [
        'callback' => '::getOrphanTranslationsCallback',
        'wrapper' => 'orphanTranslationsListWrapper',
      ],
    ];

    $form['orphanTranslations']['orphanSubmitDel'] = [
      '#type' => 'submit',
      '#value' => $this->t('Delete Orphan translations'),
      '#description' => $this->t('Delete translations, which have no target
                        translation'),
      '#submit' => ['::deleteOrphanTranslations']
    ];

    $form['statusTranslations'] = array(
      '#type' => 'details',
      '#open' => TRUE,
      '#title' => $this
        ->t('Status translations'),
      '#description' => $this->t('List/Delete translation_status entries and updates them')
    );

    $form['statusTranslations']['statusTranslationsListWrapper'] = [
      '#type' => 'container',
      '#attributes' => ['id' => 'statusTranslationsListWrapper'],
    ];

    $form['statusTranslations']['statusSubmitList'] = [
      '#type' => 'submit',
      '#value' => $this->t('Get translation_status entries'),
      '#description' => $this->t('List translation_status entries'),
      '#ajax' => [
        'callback' => '::getStatusTranslationsCallback',
        'wrapper' => 'statusTranslationsListWrapper',
      ],
    ];

    $form['statusTranslations']['statusSubmitDel'] = [
      '#type' => 'submit',
      '#value' => $this->t('Delete and Update translation_status entries'),
      '#description' => $this->t('Delete translation_status entries'),
      '#submit' => ['::deleteResetTranslationStatus']
    ];

    return $form;
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
    // TODO - Implement!
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
  public function getQuestion()
  {
  }

  /**
   * Ajax callback for the database entries dropwdown
   */
  public function getEqualTranslationsCallback(array $form, FormStateInterface $form_state)
  {
    $equalTranslationsArray = $this->getEqualTranslations();
    $form['getEqualTranslationsTable'] = [
      '#type' => 'table',
      '#caption' => $this->t('Equal translations'),
      '#header' => [
        $this->t('Lid'),
        $this->t('Source'),
        $this->t('Translation'),
      ],
      '#empty' => $this->t('No translations found!'),
    ];
    foreach ($equalTranslationsArray as $key => $equalTranslation) {
      $form['getEqualTranslationsTable'][$key]['lid'] = [
        '#markup' => $equalTranslation->lid,
      ];
      $form['getEqualTranslationsTable'][$key]['source'] = [
        '#markup' => $equalTranslation->source,
      ];
      $form['getEqualTranslationsTable'][$key]['translation'] = [
        '#markup' => $equalTranslation->translation,
      ];
    }
    return $form['getEqualTranslationsTable'];
  }

  public function getOrphanTranslationsCallback(array $form, FormStateInterface $form_state)
  {
    $orphanTranslationsArray = $this->getOrphanTranslations();
    $form['getOrphanTranslationsTable'] = [
      '#type' => 'table',
      '#caption' => $this->t('Orphan translations'),
      '#header' => [
        $this->t('Lid'),
      ],
      '#empty' => $this->t('No translations found!'),
    ];
    foreach ($orphanTranslationsArray as $key => $orphanTranslation) {
      $form['getOrphanTranslationsTable'][$key]['lid'] = [
        '#markup' => $orphanTranslation->lid,
      ];
    }
    return $form['getOrphanTranslationsTable'];
  }

  public function getStatusTranslationsCallback(array $form, FormStateInterface $form_state)
  {
    $statusTranslationsArray = $this->getStatusTranslations();
    $form['getStatusTranslationsTable'] = [
      '#type' => 'table',
      '#caption' => $this->t('Status translations'),
      '#header' => [
        $this->t('Lid'),
        $this->t('Collections'),
        $this->t('Values'),
      ],
      '#empty' => $this->t('No translations found!'),
    ];
    foreach ($statusTranslationsArray as $key => $statusTranslation) {
      $form['getStatusTranslationsTable'][$key]['name'] = [
        '#markup' => $statusTranslation->name,
      ];
      $form['getStatusTranslationsTable'][$key]['collection'] = [
        '#markup' => $statusTranslation->collection,
      ];
      $form['getStatusTranslationsTable'][$key]['value'] = [
        '#markup' => $statusTranslation->value,
      ];
    }
    return $form['getStatusTranslationsTable'];
  }



  public function deleteEqualTranslations(){
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->deleteEqualTranslations();
    if(!empty($result)){
      $this->messenger()->addMessage($result . ' equal translations deleted.');
    }
    else {
      $this->messenger()->addError('No translations found');
    }
  }

  public function getEqualTranslations(){
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->getEqualTranslations();
    return $result;
  }

  public function getOrphanTranslations()
  {
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->getOrphanTranslations();
    return $result;
  }

  public function deleteOrphanTranslations()
  {
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->deleteOrphanTranslations();
    if (!empty($result)) {
      $this->messenger()->addMessage($result . ' orphan translations deleted.');
    } else {
      $this->messenger()->addError('No Orphan translations found!');
    }
  }

  public function getStatusTranslations()
  {
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->getStatusTranslations();
    return $result;
  }

  public function deleteResetStatusTranslations()
  {
    $queryHelper = \Drupal::service('trans_cleanup.query_helper');
    $result = $queryHelper->deleteResetStatusTranslations();
    if (!empty($result)) {
      $this->messenger()->addMessage($result . ' translation_status entries deleted.');
    } else {
      $this->messenger()->addError('No deletable translation_status entries found, translation_status reset');
    }
  }
}


